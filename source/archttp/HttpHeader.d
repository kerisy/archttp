module archttp.HttpHeader;

import geario.logging;

import std.algorithm;
import std.conv;
import std.string;

/**
 * Http header name
 */
struct HttpHeader
{
    enum string NULL = "Null";

    /**
     * General Fields.
     */
    enum string CONNECTION = "Connection";
    enum string CACHE_CONTROL = "Cache-Control";
    enum string DATE = "Date";
    enum string PRAGMA = "Pragma";
    enum string PROXY_CONNECTION = "Proxy-Connection";
    enum string TRAILER = "Trailer";
    enum string TRANSFER_ENCODING = "Transfer-Encoding";
    enum string UPGRADE = "Upgrade";
    enum string VIA = "Via";
    enum string WARNING = "Warning";
    enum string NEGOTIATE = "Negotiate";

    /**
     * Entity Fields.
     */
    enum string ALLOW = "Allow";
    enum string CONTENT_DISPOSITION = "Content-Disposition";
    enum string CONTENT_ENCODING = "Content-Encoding";
    enum string CONTENT_LANGUAGE = "Content-Language";
    enum string CONTENT_LENGTH = "Content-Length";
    enum string CONTENT_LOCATION = "Content-Location";
    enum string CONTENT_MD5 = "Content-MD5";
    enum string CONTENT_RANGE = "Content-Range";
    enum string CONTENT_TYPE = "Content-Type";
    enum string EXPIRES = "Expires";
    enum string LAST_MODIFIED = "Last-Modified";

    /**
     * Request Fields.
     */
    enum string ACCEPT = "Accept";
    enum string ACCEPT_CHARSET = "Accept-Charset";
    enum string ACCEPT_ENCODING = "Accept-Encoding";
    enum string ACCEPT_LANGUAGE = "Accept-Language";
    enum string AUTHORIZATION = "Authorization";
    enum string EXPECT = "Expect";
    enum string FORWARDED = "Forwarded";
    enum string FROM = "From";
    enum string HOST = "Host";
    enum string IF_MATCH = "If-Match";
    enum string IF_MODIFIED_SINCE = "If-Modified-Since";
    enum string IF_NONE_MATCH = "If-None-Match";
    enum string IF_RANGE = "If-Range";
    enum string IF_UNMODIFIED_SINCE = "If-Unmodified-Since";
    enum string KEEP_ALIVE = "Keep-Alive";
    enum string MAX_FORWARDS = "Max-Forwards";
    enum string PROXY_AUTHORIZATION = "Proxy-Authorization";
    enum string RANGE = "Range";
    enum string REQUEST_RANGE = "Request-Range";
    enum string REFERER = "Referer";
    enum string TE = "TE";
    enum string USER_AGENT = "User-Agent";
    enum string X_FORWARDED_FOR = "X-Forwarded-For";
    enum string X_FORWARDED_PROTO = "X-Forwarded-Proto";
    enum string X_FORWARDED_SERVER = "X-Forwarded-Server";
    enum string X_FORWARDED_HOST = "X-Forwarded-Host";

    /**
     * Response Fields.
     */
    enum string ACCEPT_RANGES = "Accept-Ranges";
    enum string AGE = "Age";
    enum string ETAG = "ETag";
    enum string LOCATION = "Location";
    enum string PROXY_AUTHENTICATE = "Proxy-Authenticate";
    enum string RETRY_AFTER = "Retry-After";
    enum string SERVER = "Server";
    enum string SERVLET_ENGINE = "Servlet-Engine";
    enum string VARY = "Vary";
    enum string WWW_AUTHENTICATE = "WWW-Authenticate";

    /**
     * WebSocket Fields.
     */
    enum string ORIGIN = "Origin";
    enum string SEC_WEBSOCKET_KEY = "Sec-WebSocket-Key";
    enum string SEC_WEBSOCKET_VERSION = "Sec-WebSocket-Version";
    enum string SEC_WEBSOCKET_EXTENSIONS = "Sec-WebSocket-Extensions";
    enum string SEC_WEBSOCKET_SUBPROTOCOL = "Sec-WebSocket-Protocol";
    enum string SEC_WEBSOCKET_ACCEPT = "Sec-WebSocket-Accept";

    /**
     * Other Fields.
     */
    enum string COOKIE = "Cookie";
    enum string SET_COOKIE = "Set-Cookie";
    enum string SET_COOKIE2 = "Set-Cookie2";
    enum string MIME_VERSION = "MIME-Version";
    enum string IDENTITY = "identity";

    enum string X_POWERED_BY = "X-Powered-By";
    enum string HTTP2_SETTINGS = "HTTP2-Settings";

    enum string STRICT_TRANSPORT_SECURITY = "Strict-Transport-Security";

    /**
     * HTTP2 Fields.
     */
    enum string C_METHOD = ":method";
    enum string C_SCHEME = ":scheme";
    enum string C_AUTHORITY = ":authority";
    enum string C_PATH = ":path";
    enum string C_STATUS = ":status";

    enum string UNKNOWN = "::UNKNOWN::";
}
