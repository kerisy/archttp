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

import gear.net.TcpStream;

class HttpContext
{
    private HttpRequest _request;
    private HttpResponse _response; 
    private TcpStream _connection;
    
    this(TcpStream connection)
    {
        _connection = connection;
    }

    HttpRequest request() {
        return _request;
    }

    void request(HttpRequest request)
    {
        _request = request;
    }

    HttpResponse response() {
        if (_response is null)
            _response = new HttpResponse(this);
        return _response;
    } 

    void response(HttpResponse response)
    {
        _response = response;
    }
    
    TcpStream connection() {
        return _connection;
    }

    void send(ubyte[] buffer)
    {
        _connection.Write(buffer);
    }

    void end()
    {
        _connection.Close();
    }
}
