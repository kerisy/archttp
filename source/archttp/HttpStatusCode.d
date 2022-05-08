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

module archttp.HttpStatusCode;

enum HttpStatusCode : ushort {
    // 1XX - Informational
    CONTINUE            = 100,
    SWITCHING_PROTOCOLS = 101,
    PROCESSING          = 102,
    
    // 2XX - Success
    OK                   = 200,
    CREATED              = 201,
    ACCEPTED             = 202,
    NON_AUTHORITIVE_INFO = 203,
    NO_CONTENT           = 204,
    RESET_CONTENT        = 205,
    PARTIAL_CONTENT      = 206,
    MULTI_STATUS         = 207,
    ALREADY_REPORTED     = 208,
    IM_USED              = 226,
    
    // 3XX - Redirectional
    MULTI_CHOICES     = 300,
    MOVED_PERMANENTLY = 301,
    FOUND             = 302,
    SEE_OTHER         = 303,
    NOT_MODIFIED      = 304,
    USE_PROXY         = 305,
    SWITCH_PROXY      = 306,
    TEMP_REDIRECT     = 307,
    PERM_REDIRECT     = 308,
    
    // 4XX - Client error
    BAD_REQUEST                 = 400,
    UNAUTHORIZED                = 401,
    PAYMENT_REQUIRED            = 402,
    FORBIDDEN                   = 403,
    NOT_FOUND                   = 404,
    METHOD_NOT_ALLOWED          = 405,
    NOT_ACCEPTABLE              = 406,
    PROXY_AUTH_REQUIRED         = 407,
    REQUEST_TIMEOUT             = 408,
    CONFLICT                    = 409,
    GONE                        = 410,
    LENGTH_REQUIRED             = 411,
    PRECONDITION_FAILED         = 412,
    REQ_ENTITY_TOO_LARGE        = 413,
    REQ_URI_TOO_LONG            = 414,
    UNSUPPORTED_MEDIA_TYPE      = 415,
    REQ_RANGE_NOT_SATISFYABLE   = 416,
    EXPECTATION_FAILED          = 417,
    IM_A_TEAPOT                 = 418,
    AUTH_TIMEOUT                = 419, // not in RFC 2616
    UNPROCESSABLE_ENTITY        = 422,
    LOCKED                      = 423,
    FAILED_DEPENDENCY           = 424,
    UPGRADE_REQUIRED            = 426,
    PRECONDITION_REQUIRED       = 428,
    TOO_MANY_REQUESTS           = 429,
    REQ_HEADER_FIELDS_TOO_LARGE = 431,
    
    // 5XX - Server error
    INTERNAL_SERVER_ERROR       = 500,
    NOT_IMPLEMENTED             = 501,
    BAD_GATEWAY                 = 502,
    SERVICE_UNAVAILABLE         = 503,
    GATEWAY_TIMEOUT             = 504,
    HTTP_VERSION_NOT_SUPPORTED  = 505,
    VARIANT_ALSO_NEGOTIATES     = 506,
    INSUFFICIENT_STORAGE        = 507,
    LOOP_DETECTED               = 508,
    NOT_EXTENDED                = 510,
    NETWORK_AUTH_REQUIRED       = 511,
    NETWORK_READ_TIMEOUT_ERR    = 598,
    NETWORK_CONNECT_TIMEOUT_ERR = 599,
}

/*
 * Converts an HTTP status code into a known reason string.
 *
 * The reason string is a small line of text that gives a hint as to the underlying meaning of the
 * status code for debugging purposes.
 */
string getHttpStatusMessage(ushort status_code)
{
    switch ( status_code )
    {
    // 1XX - Informational
    case HttpStatusCode.CONTINUE:
        return "CONTINUE";
    case HttpStatusCode.SWITCHING_PROTOCOLS:
        return "SWITCHING PROTOCOLS";
    case HttpStatusCode.PROCESSING:
        return "PROCESSING";
    // 2XX - Success
    case HttpStatusCode.OK:
        return "OK";
    case HttpStatusCode.CREATED:
        return "CREATED";
    case HttpStatusCode.ACCEPTED:
        return "ACCEPTED";
    case HttpStatusCode.NON_AUTHORITIVE_INFO:
        return "NON AUTHORITIVE INFO";
    case HttpStatusCode.NO_CONTENT:
        return "NO CONTENT";
    case HttpStatusCode.RESET_CONTENT:
        return "RESET CONTENT";
    case HttpStatusCode.PARTIAL_CONTENT:
        return "PARTIAL CONTENT";
    case HttpStatusCode.MULTI_STATUS:
        return "MULTI STATUS";
    case HttpStatusCode.ALREADY_REPORTED:
        return "ALREADY REPORTED";
    case HttpStatusCode.IM_USED:
        return "IM USED";
    // 3XX - Redirectional
    case HttpStatusCode.MULTI_CHOICES:
        return "MULTI CHOICES";
    case HttpStatusCode.MOVED_PERMANENTLY:
        return "MOVED PERMANENTLY";
    case HttpStatusCode.FOUND:
        return "FOUND";
    case HttpStatusCode.SEE_OTHER:
        return "SEE OTHER";
    case HttpStatusCode.NOT_MODIFIED:
        return "NOT MODIFIED";
    case HttpStatusCode.USE_PROXY:
        return "USE PROXY";
    case HttpStatusCode.SWITCH_PROXY:
        return "SWITCH PROXY";
    case HttpStatusCode.TEMP_REDIRECT:
        return "TEMP REDIRECT";
    case HttpStatusCode.PERM_REDIRECT:
        return "PERM REDIRECT";
    // 4XX - Client error
    case HttpStatusCode.BAD_REQUEST:
        return "BAD REQUEST";
    case HttpStatusCode.UNAUTHORIZED:
        return "UNAUTHORIZED";
    case HttpStatusCode.PAYMENT_REQUIRED:
        return "PAYMENT REQUIRED";
    case HttpStatusCode.FORBIDDEN:
        return "FORBIDDEN";
    case HttpStatusCode.NOT_FOUND:
        return "NOT FOUND";
    case HttpStatusCode.METHOD_NOT_ALLOWED:
        return "METHOD NOT ALLOWED";
    case HttpStatusCode.NOT_ACCEPTABLE:
        return "NOT ACCEPTABLE";
    case HttpStatusCode.PROXY_AUTH_REQUIRED:
        return "PROXY AUTH REQUIRED";
    case HttpStatusCode.REQUEST_TIMEOUT:
        return "REQUEST TIMEOUT";
    case HttpStatusCode.CONFLICT:
        return "CONFLICT";
    case HttpStatusCode.GONE:
        return "GONE";
    case HttpStatusCode.LENGTH_REQUIRED:
        return "LENGTH REQUIRED";
    case HttpStatusCode.PRECONDITION_FAILED:
        return "PRECONDITION FAILED";
    case HttpStatusCode.REQ_ENTITY_TOO_LARGE:
        return "REQ ENTITY TOO LARGE";
    case HttpStatusCode.REQ_URI_TOO_LONG:
        return "REQ URI TOO LONG";
    case HttpStatusCode.UNSUPPORTED_MEDIA_TYPE:
        return "UNSUPPORTED MEDIA TYPE";
    case HttpStatusCode.REQ_RANGE_NOT_SATISFYABLE:
        return "REQ RANGE NOT SATISFYABLE";
    case HttpStatusCode.EXPECTATION_FAILED:
        return "EXPECTATION FAILED";
    case HttpStatusCode.IM_A_TEAPOT:
        return "IM A TEAPOT";
    case HttpStatusCode.AUTH_TIMEOUT: // not in RFC 2616
        return "AUTH TIMEOUT";
    case HttpStatusCode.UNPROCESSABLE_ENTITY:
        return "UNPROCESSABLE ENTITY";
    case HttpStatusCode.LOCKED:
        return "LOCKED";
    case HttpStatusCode.FAILED_DEPENDENCY:
        return "FAILED DEPENDENCY";
    case HttpStatusCode.UPGRADE_REQUIRED:
        return "UPGRADE REQUIRED";
    case HttpStatusCode.PRECONDITION_REQUIRED:
        return "PRECONDITION REQUIRED";
    case HttpStatusCode.TOO_MANY_REQUESTS:
        return "TOO MANY REQUESTS";
    case HttpStatusCode.REQ_HEADER_FIELDS_TOO_LARGE:
        return "REQ HEADER FIELDS TOO LARGE";
    // 5XX - Server error
    case HttpStatusCode.INTERNAL_SERVER_ERROR:
        return "INTERNAL SERVER ERROR";
    case HttpStatusCode.NOT_IMPLEMENTED:
        return "NOT IMPLEMENTED";
    case HttpStatusCode.BAD_GATEWAY:
        return "BAD GATEWAY";
    case HttpStatusCode.SERVICE_UNAVAILABLE:
        return "SERVICE UNAVAILABLE";
    case HttpStatusCode.GATEWAY_TIMEOUT:
        return "GATEWAY TIMEOUT";
    case HttpStatusCode.HTTP_VERSION_NOT_SUPPORTED:
        return "HTTP VERSION NOT SUPPORTED";
    case HttpStatusCode.VARIANT_ALSO_NEGOTIATES:
        return "VARIANT ALSO NEGOTIATES";
    case HttpStatusCode.INSUFFICIENT_STORAGE:
        return "INSUFFICIENT STORAGE";
    case HttpStatusCode.LOOP_DETECTED:
        return "LOOP DETECTED";
    case HttpStatusCode.NOT_EXTENDED:
        return "NOT EXTENDED";
    case HttpStatusCode.NETWORK_AUTH_REQUIRED:
        return "NETWORK AUTH REQUIRED";
    case HttpStatusCode.NETWORK_READ_TIMEOUT_ERR:
        return "NETWORK READ TIMEOUT ERR";
    case HttpStatusCode.NETWORK_CONNECT_TIMEOUT_ERR:
        return "NETWORK CONNECT TIMEOUT ERR";
    default:
        return "- UNKNOW STATUS CODE";
    }
}
