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

class Archttp
{
    private
    {
        TcpListener _listener;
        EventLoop _loop;
        Router!HttpRequestHandler _router;
    }

    this()
    {
        _loop = new EventLoop();
        _listener = new TcpListener(_loop);
        _router = new Router!HttpRequestHandler;
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

    Archttp Bind(ushort port)
    {
        _listener.Bind(port);
        _listener.Accepted((TcpListener sender, TcpStream connection)
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
            });

        return this;
    }

    void Run()
    {
        Infof("Listening on: %s", _listener.BindingAddress.toString());

        _listener.Start();
        _loop.Run();
    }
}
