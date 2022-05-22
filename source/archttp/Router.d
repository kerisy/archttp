/*
 * Router - A highly performant web framework written in D.
 *
 * Copyright (C) 2021-2022 Kerisy.com
 *
 * Website: https://www.kerisy.com
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module archttp.Router;

public import archttp.Route;
public import archttp.HttpMethod;

import archttp.Archttp;

import std.stdio;

import std.regex : regex, match, matchAll;
import std.array : replaceFirst;
import std.uri : decode;

class Router(RoutingHandler, MiddlewareHandler)
{
    private
    {
        Route!(RoutingHandler, MiddlewareHandler)[string] _routes;
        Route!(RoutingHandler, MiddlewareHandler)[string] _regexRoutes;
        MiddlewareHandler[] _middlewareHandlers;
        Archttp _app;
    }
    
    Router add(string path, HttpMethod method, RoutingHandler handler)
    {
        Router route;

        route = _routes.get(path, null);
        if (route is null)
        {
            route = _regexRoutes.get(path, null);
        }

        if (route is null)
        {
            route = CreateRoute(path, method, handler);

            if (route.regular)
            {
                _regexRoutes[path] = route;
            }
            else
            {
                _routes[path] = route;
            }
        }
        else
        {
            route.bindMethod(method, handler);
        }

        return this;
    }

    Router get(string route, RoutingHandler handler)
    {
        add(route, HttpMethod.GET, handler);
        return this;
    }

    Router post(string route, RoutingHandler handler)
    {
        add(route, HttpMethod.POST, handler);
        return this;
    }

    Router put(string route, RoutingHandler handler)
    {
        add(route, HttpMethod.PUT, handler);
        return this;
    }

    Router Delete(string route, RoutingHandler handler)
    {
        add(route, HttpMethod.DELETE, handler);
        return this;
    }

    Router use(MiddlewareHandler handler)
    {
        _middlewareHandlers ~= handler;
        return this;
    }

    void onMount(Archttp app)
    {
        _app = app;
    }

    MiddlewareHandler[] middlewareHandlers()
    {
        return _middlewareHandlers;
    }

    private Route!(RoutingHandler, MiddlewareHandler) CreateRoute(string path, HttpMethod method, RoutingHandler handler)
    {
        auto route = new Route!(RoutingHandler, MiddlewareHandler)(path, method, handler);

        auto matches = path.matchAll(regex(`\{(\w+)(:([^\}]+))?\}`));
        if (matches)
        {
            string[uint] paramKeys;
            int paramCount = 0;
            string pattern = path;
            string urlTemplate = path;

            foreach (m; matches)
            {
                paramKeys[paramCount] = m[1];
                string reg = m[3].length ? m[3] : "\\w+";
                pattern = pattern.replaceFirst(m[0], "(" ~ reg ~ ")");
                urlTemplate = urlTemplate.replaceFirst(m[0], "{" ~ m[1] ~ "}");
                paramCount++;
            }

            route.pattern = pattern;
            route.paramKeys = paramKeys;
            route.regular = true;
            route.urlTemplate = urlTemplate;
        }

        return route;
    }

    RoutingHandler match(string path, HttpMethod method, ref MiddlewareHandler[] middlewareHandlers, ref string[string] params)
    {
        auto route = _routes.get(path, null);

        if (route is null)
        {
            foreach ( r ; _regexRoutes )
            {
                auto matched = path.match(regex(r.pattern));

                if (matched)
                {
                    route = r;
                    
                    foreach ( i, key ; route.paramKeys )
                    {
                        params[key] = decode(matched.captures[i + 1]);
                    }
                }
            }
        }

        if (route is null)
        {
            writeln(path, " is Not Found.");
            return cast(RoutingHandler) null;
        }

        RoutingHandler handler;
        handler = route.find(method);

        if (handler is null)
        {
            writeln("Request: ", path, " method ", method, " is Not Allowed.");
            return cast(RoutingHandler) null;
        }

        middlewareHandlers = route.middlewareHandlers();

        return handler;
    }
}
