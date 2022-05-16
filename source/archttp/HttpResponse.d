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

module archttp.HttpResponse;

import archttp.HttpStatusCode;
import archttp.HttpContext;
import archttp.Cookie;

import geario.util.DateTime;
import geario.logging;

import std.format;
import std.array;
import std.conv : to;
import std.json;

class HttpResponse
{
    private
    {
        ushort         _statusCode = HttpStatusCode.OK;
        string[string] _headers;
        string         _body;
        string         _buffer;
        HttpContext    _httpContext;
        Cookie[string] _cookies;

        // for ..
        bool         _headersSent = false;
    }

public:
    /*
     * Construct an empty response.
     */
    this(HttpContext ctx)
    {
        _httpContext = ctx;
    }

    bool headerSent()
    {
        return _headersSent;
    }

    HttpResponse header(string header, string value)
    {
        _headers[header] = value;
        
        return this;
    }

    HttpResponse code(HttpStatusCode statusCode)
    {
        _statusCode = statusCode;

        return this;
    }

    ushort code()
    {
        return _statusCode;
    }

    HttpResponse cookie(string name, string value, string path = "/", string domain = "", string expires = "", long maxAge = -1, bool secure = false, bool httpOnly = false)
    {
        _cookies[name] = new Cookie(name, value, path, domain, expires, maxAge, secure, httpOnly);
        return this;
    }

    HttpResponse cookie(Cookie cookie)
    {
        _cookies[cookie.name()] = cookie;
        return this;
    }

    Cookie cookie(string name)
    {
        return _cookies.get(name, null);
    }

    void send(string body)
    {
        _body = body;
        send();
    }

    void send(JSONValue json)
    {
        _body = json.toString();
        
        header("Content-Type", "application/json");
        send();
    }

    void send()
    {
        if (_headersSent)
        {
            LogErrorf("Can't set headers after they are sent");
            return;
        }

        _httpContext.Send(this);
        _headersSent = true;
    }

    HttpResponse json(JSONValue json)
    {
        _body = json.toString();

        header("Content-Type", "application/json");

        return this;
    }

    HttpResponse location(HttpStatusCode statusCode, string path)
    {
        code(statusCode);
        location(path);
    }

    HttpResponse location(string path)
    {
        redirect(HttpStatusCode.SEE_OTHER, path);
        header("Location", path);
    }

    HttpResponse redirect(HttpStatusCode statusCode, string path)
    {
        location(statusCode, path);
    }

    HttpResponse redirect(string path)
    {
        redirect(HttpStatusCode.FOUND, path);
    }

    void end()
    {
        _httpContext.End();
    }

    override string toString()
    {
        header("Content-Length", _body.length.to!string);
        header("Date", DateTime.GetTimeAsGMT());

        auto text = appender!string;
        text ~= format!"HTTP/1.1 %d %s\r\n"(_statusCode, getHttpStatusMessage(_statusCode));
        foreach (name, value; _headers) {
            text ~= format!"%s: %s\r\n"(name, value);
        }

        if (_cookies.length)
        {
            foreach (cookie ; _cookies)
            {
                text ~= format!"Set-Cookie: %s\r\n"(cookie.toString());
            }
        }

        text ~= "\r\n";

        text ~= _body;
        
        return text[];
    }
}
