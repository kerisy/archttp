/*
 * Archttp - A highly performant web framework written in D.
 *
 * Copyright (C) 2021-2022 Kerisy.com
 *
 * Website: https://www.kerisy.com
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module archttp.Route;

import archttp.HttpMethod;

import std.stdio;

class Route(RoutingHandler, MiddlewareHandler)
{
    private
    {
        string _path;

        RoutingHandler[HttpMethod] _handlers;
        MiddlewareHandler[] _middlewareHandlers;
    }

    public
    {
        // like uri path
        string pattern;

        // use regex?
        bool regular;

        // Regex template
        string urlTemplate;

        string[uint] paramKeys;
    }
    
    this(string path, HttpMethod method, RoutingHandler handler)
    {
        _path = path;

        bindMethod(method, handler);
    }

    Route bindMethod(HttpMethod method, RoutingHandler handler)
    {
        _handlers[method] = handler;
        return this;
    }

    Route use(MiddlewareHandler handler)
    {
        _middlewareHandlers ~= handler;
        return this;
    }

    MiddlewareHandler[] middlewareHandlers()
    {
        return _middlewareHandlers;
    }

    RoutingHandler find(HttpMethod method)
    {
        auto handler = _handlers.get(method, null);

        return cast(RoutingHandler) handler;
    }

    string path()
    {
        return _path;
    }
}
