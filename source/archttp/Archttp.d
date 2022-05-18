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

import archttp.HttpRequestHandler;
import archttp.Router;

import std.socket;
import std.experimental.allocator;

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

        Router!HttpRequestHandler _router;
    }

    this(uint ioThreads = totalCPUs, uint workerThreads = 0)
    {
        _ioThreads = ioThreads > 1 ? ioThreads : 1;
        _workerThreads = workerThreads;

        _router = new Router!HttpRequestHandler;
        _loop = new EventLoop;
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

    private void handle(HttpContext httpContext)
    {
        auto handler = _router.match(httpContext.request().path(), httpContext.request().method(), httpContext.request().params);

        if (handler is null)
        {
            httpContext.response().code(HttpStatusCode.NOT_FOUND).send("404 Not Found.");
        }
        else
        {
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
