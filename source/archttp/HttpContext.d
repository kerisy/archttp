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

import gear.codec.Framed;

alias Framed!(HttpRequest, HttpResponse) HttpFramed;

class HttpContext
{
    private HttpRequest _request;
    private HttpResponse _response;
    private HttpFramed _framed;
    
    this(HttpFramed framed)
    {
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

    void Send(HttpResponse response)
    {
        _framed.Send(response);
    }

    void End()
    {
        // _connection.Close();
    }
}
