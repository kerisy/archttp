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
import geario.logging;

alias Framed!(HttpRequest, HttpResponse) HttpFramed;

class HttpContext
{
    private HttpRequest _request;
    private HttpResponse _response;
    private TcpStream _connection;
    private HttpFramed _framed;
    private bool _keepAlive;
    private bool _keepAliveSetted;
    
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
        _request.context(this);

        initKeepAliveValue();
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

    TcpStream connection()
    {
        return _connection;
    }

    bool keepAlive()
    {
        return _keepAlive;
    }

    private void initKeepAliveValue()
    {
        if (false == _keepAliveSetted)
        {
            string connectionType = _request.header("Connection");
            if (connectionType.length && connectionType == "keep-alive")
                _keepAlive = true;
            else
                _keepAlive = false;

            _keepAliveSetted = true;
        }
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
