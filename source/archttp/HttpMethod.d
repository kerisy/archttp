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

module archttp.HttpMethod;

/*
 * HTTP method enum
 */
enum HttpMethod : ushort {
    GET,
    POST,
    HEAD,
    PUT,
    DELETE,
    OPTIONS,
    TRACE,
    CONNECT,
    BREW,
    PATCH
}

HttpMethod getHttpMethodFromString(string method)
{
    switch (method)
    {
        case "GET":
            return HttpMethod.GET;
        case "POST":
            return HttpMethod.POST;
        case "HEAD":
            return HttpMethod.HEAD;
        case "PUT":
            return HttpMethod.PUT;
        case "DELETE":
            return HttpMethod.DELETE;
        case "OPTIONS":
            return HttpMethod.OPTIONS;
        case "TRACE":
            return HttpMethod.TRACE;
        case "CONNECT":
            return HttpMethod.CONNECT;
        case "BREW":
            return HttpMethod.BREW;
        case "PATCH":
            return HttpMethod.PATCH;
        default:
            return HttpMethod.GET; // show error?
    }
}
