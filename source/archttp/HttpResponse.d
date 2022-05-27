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
import archttp.HttpHeader;

import nbuff;

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
        ubyte[]        _buffer;
        HttpContext    _httpContext;
        Cookie[string] _cookies;

        // for ..
        bool           _headersSent = false;
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

    HttpResponse cookie(string name, string value, string path = "/", string domain = "", string expires = "", long maxAge = 604800, bool secure = false, bool httpOnly = false)
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
            log.error("Can't set headers after they are sent");
            return;
        }

        if (sendHeader())
            sendBody();
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

        return this;
    }

    HttpResponse location(string path)
    {
        redirect(HttpStatusCode.SEE_OTHER, path);
        header("Location", path);
        return this;
    }

    HttpResponse redirect(HttpStatusCode statusCode, string path)
    {
        location(statusCode, path);
        return this;
    }

    HttpResponse redirect(string path)
    {
        redirect(HttpStatusCode.FOUND, path);
        return this;
    }

    HttpResponse sendFile(string path, string filename = "")
    {
        import std.stdio : File;
        
        auto file = File(path, "r");
        auto fileSize = file.size();

        if (filename.length == 0)
        {
            import std.array : split;
            import std.string : replace;

            auto parts = path.replace("\\", "/").split("/");
            if (parts.length == 1)
            {
                filename = path;
            }
            else
            {
                filename = parts[parts.length - 1];
            }
        }

        header(HttpHeader.CONTENT_DISPOSITION, "attachment; filename=" ~ filename ~ "; size=" ~ fileSize.to!string);
        header(HttpHeader.CONTENT_LENGTH, fileSize.to!string);

        _httpContext.Write(headerToString());
        _headersSent = true;
        
        auto buf = Nbuff.get(fileSize);
        file.rawRead(buf.data());

        _httpContext.Write(NbuffChunk(buf, fileSize));
        reset();

        return this;
    }

    void end()
    {
        reset();
        _httpContext.End();
    }

    private bool sendHeader()
    {
        if (_headersSent)
        {
            log.error("Can't set headers after they are sent");
            return false;
        }
        
        // if (_httpContext.keepAlive() && this.header(HttpHeader.CONTENT_LENGTH).length == 0)
        header(HttpHeader.CONTENT_LENGTH, _body.length.to!string);

        _httpContext.Write(headerToString());
        _headersSent = true;

        return true;
    }

    private void sendBody()
    {
        _httpContext.Write(_body);
        reset();
    }

    void reset()
    {
        // clear request object
        _httpContext.request().reset();

        _statusCode = HttpStatusCode.OK;
        _headers = null;
        _body = null;
        _buffer = null;
        _cookies = null;
        _headersSent = false;
    }

    string headerToString()
    {
        header(HttpHeader.SERVER, "Archttp");
        header(HttpHeader.DATE, DateTime.GetTimeAsGMT());

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
        
        return text[];
    }
}
