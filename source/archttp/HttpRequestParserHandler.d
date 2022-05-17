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

module archttp.HttpRequestParserHandler;

import archttp.HttpRequest;
import archttp.HttpMessageParser;

import std.stdio : writeln;
import std.conv : to;

import archttp.Url;

class HttpRequestParserHandler : HttpMessageHandler
{
    this(HttpRequest request = null)
    {
        this._request = request;
        if (_request is null)
            _request = new HttpRequest;
    }

    void onMethod(const(char)[] method)
    {
        _request.method(getHttpMethodFromString(method.to!string));
    }

    void onUri(const(char)[] uri)
    {
        _request.uri(Url(uri.to!string));
    }

    int onVersion(const(char)[] ver)
    {
        auto minorVer = parseHttpVersion(ver);
        return minorVer >= 0 ? 0 : minorVer;
    }

    void onHeader(const(char)[] name, const(char)[] value)
    {
        _request.header(name.to!string, value.to!string);
    }

    void onStatus(int status) {
        // Request 不处理
    }

    void onStatusMsg(const(char)[] statusMsg) {
        // Request 不处理
    }

    HttpRequest request()
    {
        return _request;
    }

    // void reset()
    // {
    //     _request.reset();
    // }

    private HttpRequest _request;
}
