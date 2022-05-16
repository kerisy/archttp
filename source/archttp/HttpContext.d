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

module archttp.HttpContext;

import archttp.HttpRequest;
import archttp.HttpResponse;

import nbuff;

import geario.net.TcpStream;
import geario.codec.Framed;

alias Framed!(HttpRequest, HttpResponse) HttpFramed;

class HttpContext
{
    private HttpRequest _request;
    private HttpResponse _response;
    private TcpStream _connection;
    private HttpFramed _framed;
    
    this(TcpStream connection, HttpFramed framed)
    {
        _connection = connection;
        _framed = framed;
    }

    HttpRequest request() {
        return _request;
    }

    void request(HttpRequest request)
    {
        _request = request;
    }

    HttpResponse response()
    {
        if (_response is null)
            _response = new HttpResponse(this);

        return _response;
    }

    void response(HttpResponse response)
    {
        _response = response;
    }

    void Write(string data)
    {
        _connection.Write(cast(ubyte[])data);
    }

    void Write(NbuffChunk bytes)
    {
        _connection.Write(bytes);
    }

    void Send(HttpResponse response)
    {
        _framed.Send(response);
    }

    void End()
    {
        _connection.Close();
    }
}
