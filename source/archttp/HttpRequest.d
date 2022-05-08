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

import archttp.Url;

public import archttp.HttpMethod;
public import archttp.MultiPart;

class HttpRequest
{
    private
    {
        HttpMethod     _method;
        Url            _uri;
        string         _path;
        string         _httpVersion;
        string[string] _headers;
        string         _body;
    }

    public
    {

        string[string] query;
        string[string] parameters;
        string[string] fields;
        MultiPart[] files;
    }

public:

    ~ this()
    {
        // TODO clean upload files
        // foreach ( file ; _files)
        // {
        //     // remove(file.tmpfile);
        // }
    }

    /*
     * Set the HTTP method of this request.
     *
     * @param method the HTTP method
     */
    void method(HttpMethod method)
    {
        _method = method;
    }

    /*
     * Set the destination of this request.
     *
     * The destination is the URL path of the request, used to determine which resource is being
     * requested.
     *
     * @param destination the URI of the request
     */
    void uri(Url uri)
    {
        _uri = uri;
        _path = _uri.path;
    }

    void path(string path)
    {
        _path = path;
    }

    /*
     * Set the HTTP version of this request.
     *
     * Sets the HTTP protocol version of this request.
     *
     * @param http_version the HTTP protocol version
     */
    void httpVersion(string http_version)
    {
        // TODO
    }

    /*
     * Set a header value of this request.
     *
     * @param header the key of the header to be set
     * @param value the value of the header
     */
    void header(string header, string value)
    {
        _headers[header] = value;
    }

    /*
     * Set the body of the request.
     *
     * @param body the body of the request
     */
    void body(string body)
    {
        _body = body;
    }

    /*
     * Obtain a reference to the URL of this request.
     *
     * @return a reference to the URL
     */
    Url uri()
    {
        return _uri;
    }

    string path()
    {
        return _path;
    }

    /*
     * Get the HTTP method of the request.
     *
     * @return HTTP method of the request
     */
    HttpMethod method()
    {
        return _method;
    }

    /*
     * Get the HTTP version of the request.
     *
     * @return HTTP version of the request
     */
    string httpVersion()
    {
        // TODO
        
        return null;
    }

    /*
     * Get a header value from this request.
     *
     * @param name the key of the header to obtain
     *
     * @return either the header value, or an empty string if the header does not exist
     */
    string header(string name)
    {
        return _headers.get(name, "");
    }

    string[string] headers()
    {
        return _headers;
    }

    /*
     * Get the body of the request.
     *
     * @return the body of the request
     */
    string body()
    {
        return _body;
    }
}
