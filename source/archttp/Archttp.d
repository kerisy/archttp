/*
 * Archttp - A highly performant web framework written in D.
 *
 * Copyright (C) 2021 Kerisy.com
 *
 * Website: https://www.kerisy.com
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module archttp.Archttp;

import nbuff;

import geario.codec;

import geario.event;
import geario.logging.ConsoleLogger;

import geario.net.TcpListener;
import geario.net.TcpStream;

import geario.util.worker;
import geario.util.DateTime;

import geario.system.Memory : totalCPUs;

// for gear http
import geario.codec.Framed;
import archttp.codec.HttpCodec;

public import archttp.HttpContext;
public import archttp.HttpRequest;
public import archttp.HttpResponse;
public import archttp.HttpStatusCode;
public import archttp.HttpContext;
public import archttp.HttpMethod;

import archttp.HttpRequestHandler;
import archttp.MiddlewareExecutor;

import std.socket;
import std.experimental.allocator;

import archttp.Router;

alias Router!(HttpRequestHandler, HttpRequestMiddlewareHandler) Routing;

class Archttp
{
    private
    {
        uint _ioThreads;
        uint _workerThreads;

        Address _addr;
        string _host;
        ushort _port;

        bool _isRunning = false;

        TcpListener _listener;
        EventLoop _loop;

        Routing _router;
        Routing[string] _mountedRouters;
        ulong _mountedRoutersMaxLength;
    }

    this(uint ioThreads = totalCPUs, uint workerThreads = 0)
    {
        _ioThreads = ioThreads > 1 ? ioThreads : 1;
        _workerThreads = workerThreads;

        _router = new Routing;
        _loop = new EventLoop;
    }

    static Routing newRouter()
    {
        return new Routing;
    }

    Archttp use(HttpRequestMiddlewareHandler handler)
    {
        _router.use(handler);
        return this;
    }

    Archttp get(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.GET, handler);
        return this;
    }

    Archttp post(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.POST, handler);
        return this;
    }

    Archttp put(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.PUT, handler);
        return this;
    }

    Archttp Delete(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.DELETE, handler);
        return this;
    }

    Archttp use(string path, Routing router)
    {
        _mountedRouters[path] = router;
        router.onMount(this);

        return this;
    }

    private void handle(HttpContext httpContext)
    {
        import std.string : indexOf, stripRight;

        Routing router;
        string path = httpContext.request().path().length > 1 ? httpContext.request().path().stripRight("/") : httpContext.request().path();

        // check app mounted routers
        if (_mountedRouters.length && path.length > 1)
        {
            string mountpath = path;

            long index = path[1 .. $].indexOf("/");

            if (index > 0)
            {
                index++;
                mountpath = path[0 .. index];
            }

            router = _mountedRouters.get(mountpath, null);
            if (router !is null)
            {
                if (mountpath.length == path.length)
                    path = "/";
                else
                    path = path[index .. $];
            }

            // Tracef("mountpath: %s, path: %s", mountpath, path);
        }

        if (router is null)
            router = _router;

        // use middlewares for Router
        MiddlewareExecutor(httpContext.request(), httpContext.response(), router.middlewareHandlers()).execute();

        auto handler = router.match(path, httpContext.request().method(), httpContext.request().middlewareHandlers, httpContext.request().params);

        if (handler is null)
        {
            httpContext.response().code(HttpStatusCode.NOT_FOUND).send("404 Not Found.");
        }
        else
        {
            // use middlewares for HttpRequestHandler
            MiddlewareExecutor(httpContext.request(), httpContext.response(), httpContext.request().middlewareHandlers).execute();
            handler(httpContext.request(), httpContext.response());

            if (!httpContext.response().headerSent())
                httpContext.response().send();
        }
        
        if (!httpContext.keepAlive())
            httpContext.End();
    }

    private void accepted(TcpListener listener, TcpStream connection)
    {
        auto codec = new HttpCodec();
        auto framed = codec.CreateFramed(connection);
        auto context = new HttpContext(connection, framed);

        framed.OnFrame((HttpRequest request)
            {
                context.request(request);
                handle(context);
            });

        connection.Error((IoError error) { 
                Errorf("Error occurred: %d  %s", error.errorCode, error.errorMsg); 
            });
    }

    Archttp bind(string host, ushort port)
    {
        _host = host;
        _port = port;
        _addr = new InternetAddress(host, port);

        return this;
    }

    Archttp bind(ushort port)
    {
        return bind("0.0.0.0", port);
    }

    void listen(ushort port)
    {
        this.bind(port);
        this.run();
    }

    void run()
    {
        DateTime.StartClock();

		Infof("io threads: %d", _ioThreads);
		// Infof("worker threads: %d", _workerThreads);

        TcpListener _listener = new TcpListener(_loop, _addr.addressFamily);

        _listener.Threads(_ioThreads);
        _listener.Bind(_addr).Listen(1024);
        _listener.Accepted(&accepted);
        _listener.Start();
        
        _isRunning = true;
        _loop.Run();
    }
}
