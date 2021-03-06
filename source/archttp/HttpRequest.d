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

module archttp.HttpRequest;

import geario.logging;

import archttp.Url;
import archttp.HttpContext;
import archttp.HttpHeader;
import archttp.HttpRequestHandler;

public import archttp.HttpMethod;
public import archttp.MultiPart;

import std.uni : toLower;

class HttpRequest
{
    private
    {
        HttpMethod     _method;
        Url            _uri;
        string         _path;
        string         _httpVersion = "HTTP/1.1";
        string[string] _headers;
        string         _body;

        HttpContext    _httpContext;
        string[string] _cookies;
        bool           _cookiesParsed;
    }

    public
    {
        // string[string] query;
        string[string] params;
        string[string] fields;
        MultiPart[] files;
        HttpRequestMiddlewareHandler[] middlewareHandlers;
    }

public:

    ~ this()
    {
        reset();
    }

    HttpRequest context(HttpContext context)
    {
        _httpContext = context;
        return this;
    }

    void method(HttpMethod method)
    {
        _method = method;
    }

    void uri(Url uri)
    {
        _uri = uri;
        _path = _uri.path;
    }

    void path(string path)
    {
        _path = path;
    }

    string ip()
    {
        return _httpContext.connection().RemoteAddress().toAddrString();
    }

    string[string] cookies()
    {
        parseCookieWhenNeeded();

        return _cookies;
    }

    string cookie(T = string)(string name)
    {
        import std.conv : to;

        parseCookieWhenNeeded();

        return _cookies.get(name, "").to!T;
    }

    void parseCookieWhenNeeded()
    {
        if (_cookiesParsed)
            return;

        _cookiesParsed = true;
    
		string cookieString = header(HttpHeader.COOKIE);
        
        if (!cookieString.length)
            return;
        
        import std.array : split;
        import std.uri : decodeComponent;
        import std.string : strip;
        
        foreach (part; cookieString.split(";"))
        {
            auto c = part.split("=");
            _cookies[decodeComponent(c[0].strip)] = decodeComponent(c[1]);
        }
    }

    HttpRequest httpVersion(string httpVersion)
    {
        _httpVersion = httpVersion;
        return this;
    }

    HttpRequest header(string header, string value)
    {
        _headers[header.toLower] = value;
        return this;
    }

    HttpRequest body(string body)
    {
        _body = body;
        return this;
    }

    Url uri()
    {
        return _uri;
    }

    string path()
    {
        return _path;
    }

    HttpMethod method()
    {
        return _method;
    }

    string httpVersion()
    {
        return _httpVersion;
    }

    string header(string name)
    {
        return _headers.get(name.toLower, "");
    }

    string[string] headers()
    {
        return _headers;
    }

    string body()
    {
        return _body;
    }

    string query(string key)
    {
        return _uri.queryParams[key].front;
    }

    string param(string key)
    {
        return params.get(key, "");
    }

    void reset()
    {
        _headers = null;
        _body = null;
        _httpVersion = null;
        _cookies = null;
        _cookiesParsed = false;

        // query = null;
        params = null;
        fields = null;
        files = null;
    }
}
