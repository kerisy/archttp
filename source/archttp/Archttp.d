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

import gear.codec;

import gear.event;
import gear.logging.ConsoleLogger;

import gear.net.TcpListener;
import gear.net.TcpStream;

import gear.system.Memory : totalCPUs;

// for gear http
import gear.codec.Framed;
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

        // for multi-threaded
        TcpListener[] _listeners;
        EventLoopGroup _loopGroup;
        
        // for single-thread
        TcpListener _listener;
        EventLoop _loop;

        Router!HttpRequestHandler _router;
    }

    this(uint ioThreads = (totalCPUs - 1), uint workerThreads = 0)
    {
        _ioThreads = ioThreads > 1 ? ioThreads : 1;
        _workerThreads = workerThreads;
        _router = new Router!HttpRequestHandler;

        if (_ioThreads > 1)
            _loopGroup = new EventLoopGroup(ioThreads);
        else
            _loop = new EventLoop();
    }

    Archttp Get(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.GET, handler);
        return this;
    }

    Archttp Post(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.POST, handler);
        return this;
    }

    Archttp Put(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.PUT, handler);
        return this;
    }

    Archttp Delete(string route, HttpRequestHandler handler)
    {
        _router.add(route, HttpMethod.DELETE, handler);
        return this;
    }

    private void Handle(HttpContext httpContext)
    {
        auto handler = _router.match(httpContext.request().path(), httpContext.request().method(), httpContext.request().parameters);

        if (handler is null)
        {
            httpContext.Send(httpContext.response().status(HttpStatusCode.NOT_FOUND).body("404 Not Found."));
        }
        else
        {
            httpContext.Send(handler(httpContext));
        }

        httpContext.End();
    }

    private TcpListener CreateListener(EventLoop loop)
    {
		TcpListener listener = new TcpListener(loop, _addr.addressFamily);

        if ( _ioThreads > 0 )
		    listener.ReusePort(true);

		listener.Bind(_addr).Listen(1024);
        listener.Accepted(&Accepted);
		listener.Start();

        return listener;
	}

    private void Accepted(TcpListener listener, TcpStream connection)
    {
        auto codec = new HttpCodec();
        auto framed = codec.CreateFramed(connection);

        framed.OnFrame((HttpRequest request)
            {
                HttpContext ctx = new HttpContext(framed);
                ctx.request(request);
                Handle(ctx);
            });

        connection.Error((IoError error) { 
                Errorf("Error occurred: %d  %s", error.errorCode, error.errorMsg); 
            });
    }

    Archttp Bind(string host, ushort port)
    {
        _host = host;
        _port = port;
        _addr = new InternetAddress(host, port);

        return this;
    }

    Archttp Bind(ushort port)
    {
        return Bind("0.0.0.0", port);
    }

    void Run()
    {
		Infof("io threads: %d", _ioThreads);
		Infof("worker threads: %d", _workerThreads);

        if (_ioThreads > 1)
        {
            _loopGroup.Start();

            foreach ( loop ; _loopGroup.Loops() )
            {
                _listeners ~= CreateListener(loop);
            }

            _isRunning = true;
        }
        else
        {
            _listener = CreateListener(_loop);
            _isRunning = true;
            _loop.Run();
        }
    }
}
