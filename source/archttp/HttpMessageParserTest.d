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

module archttp.HttpMessageParserTest;

import archttp.HttpMessageParser;

///
@("example")
unittest
{
    auto reqHandler = new HttpRequestParserHandler;
    auto reqParser = new HttpMessageParser(reqHandler);

    auto resHandler = new HttpRequestParserHandler;
    auto resParser = new HttpMessageParser(resHandler);

    // parse request
    string data = "GET /foo HTTP/1.1\r\nHost: 127.0.0.1:8090\r\n\r\n";
    // returns parsed message header length when parsed sucessfully, -ParserError on error
    int res = reqParser.parseRequest(data);
    assert(res == data.length);
    assert(reqHandler.method == "GET");
    assert(reqHandler.uri == "/foo");
    assert(reqHandler.minorVer == 1); // HTTP/1.1
    assert(reqHandler.headers.length == 1);
    assert(reqHandler.headers[0].name == "Host");
    assert(reqHandler.headers[0].value == "127.0.0.1:8090");

    // parse response
    data = "HTTP/1.0 200 OK\r\n";
    uint lastPos; // store last parsed position for next run
    res = resParser.parseResponse(data, lastPos);
    assert(res == -ParserError.partial); // no complete message header yet
    data = "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 3\r\n\r\nfoo";
    res = resParser.parseResponse(data, lastPos); // starts parsing from previous position
    assert(res == data.length - 3); // whole message header parsed, body left to be handled based on actual header values
    assert(resHandler.minorVer == 0); // HTTP/1.0
    assert(resHandler.status == 200);
    assert(resHandler.statusMsg == "OK");
    assert(resHandler.headers.length == 2);
    assert(resHandler.headers[0].name == "Content-Type");
    assert(resHandler.headers[0].value == "text/plain");
    assert(resHandler.headers[1].name == "Content-Length");
    assert(resHandler.headers[1].value == "3");
}

@("parseHttpVersion")
unittest
{
    assert(parseHttpVersion("FOO") < 0);
    assert(parseHttpVersion("HTTP/1.") < 0);
    assert(parseHttpVersion("HTTP/1.12") < 0);
    assert(parseHttpVersion("HTTP/1.a") < 0);
    assert(parseHttpVersion("HTTP/2.0") < 0);
    assert(parseHttpVersion("HTTP/1.00") < 0);
    assert(parseHttpVersion("HTTP/1.0") == 0);
    assert(parseHttpVersion("HTTP/1.1") == 1);
}

version (CI_MAIN)
{
    // workaround for dub not supporting unittests with betterC
    version (D_BetterC)
    {
        extern(C) void main() @trusted {
            import core.stdc.stdio;
            static foreach(u; __traits(getUnitTests, httparsed))
            {
                static if (__traits(getAttributes, u).length)
                    printf("unittest %s:%d | '" ~ __traits(getAttributes, u)[0] ~ "'\n", __traits(getLocation, u)[0].ptr, __traits(getLocation, u)[1]);
                else
                    printf("unittest %s:%d\n", __traits(getLocation, u)[0].ptr, __traits(getLocation, u)[1]);
                u();
            }
            debug printf("All unit tests have been run successfully.\n");
        }
    }
    else
    {
        void main()
        {
            version (unittest) {} // run automagically
            else
            {
                import core.stdc.stdio;

                // just a compilation test
                auto reqParser = initParser();
                auto resParser = initParser();

                string data = "GET /foo HTTP/1.1\r\nHost: 127.0.0.1:8090\r\n\r\n";
                int res = reqHandler.parseRequest(data);
                assert(res == data.length);

                data = "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 3\r\n\r\nfoo";
                res = resHandler.parseResponse(data);
                assert(res == data.length - 3);
                () @trusted { printf("Test app works\n"); }();
            }
        }
    }
}


/// Builds valid char map from the provided ranges of invalid ones
bool[256] buildValidCharMap()(string invalidRanges)
{
    assert(invalidRanges.length % 2 == 0, "Uneven ranges");
    bool[256] res = true;

    for (int i=0; i < invalidRanges.length; i+=2)
        for (int j=invalidRanges[i]; j <= invalidRanges[i+1]; ++j)
            res[j] = false;
    return res;
}

@("buildValidCharMap")
unittest
{
    string ranges = "\0 \"\"(),,//:@[]{{}}\x7f\xff";
    assert(buildValidCharMap(ranges) ==
        cast(bool[])[
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,1,0,1,1,1,1,1,0,0,1,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,
            0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        ]);
}

version (unittest) version = WITH_MSG;
else version (CI_MAIN) version = WITH_MSG;

version (WITH_MSG)
{
    // define our message content handler
    struct Header
    {
        const(char)[] name;
        const(char)[] value;
    }

    // Just store slices of parsed message header
    class HttpRequestParserHandler : HttpMessageHandler
    {
        @safe pure nothrow @nogc:
        void onMethod(const(char)[] method) { this.method = method; }
        void onUri(const(char)[] uri) { this.uri = uri; }
        int onVersion(const(char)[] ver)
        {
            minorVer = parseHttpVersion(ver);
            return minorVer >= 0 ? 0 : minorVer;
        }
        void onHeader(const(char)[] name, const(char)[] value) {
            this.m_headers[m_headersLength].name = name;
            this.m_headers[m_headersLength++].value = value;
        }
        void onStatus(int status) { this.status = status; }
        void onStatusMsg(const(char)[] statusMsg) { this.statusMsg = statusMsg; }

        const(char)[] method;
        const(char)[] uri;
        int minorVer;
        int status;
        const(char)[] statusMsg;

        private {
            Header[32] m_headers;
            size_t m_headersLength;
        }

        Header[] headers() return { return m_headers[0..m_headersLength]; }
    }

    enum Test { err, complete, partial }
}

// Tests from https://github.com/h2o/picohttpparser/blob/master/test.c

@("Request")
unittest
{
    auto parse(string data, Test test = Test.complete, int additional = 0)
    {
        auto parser = new HttpMessageParser(new HttpRequestParserHandler);
        auto res = parser.parseRequest(data);
        // if (res < 0) writeln("Err: ", cast(ParserError)(-res));
        final switch (test)
        {
            case Test.err: assert(res < -ParserError.partial); break;
            case Test.partial: assert(res == -ParserError.partial); break;
            case Test.complete: assert(res == data.length - additional); break;
        }

        return cast(HttpRequestParserHandler) parser.messageHandler();
    }

    // simple
    {
        auto req = parse("GET / HTTP/1.0\r\n\r\n");
        assert(req.headers.length == 0);
        assert(req.method == "GET");
        assert(req.uri == "/");
        assert(req.minorVer == 0);
    }

    // parse headers
    {
        auto req = parse("GET /hoge HTTP/1.1\r\nHost: example.com\r\nCookie: \r\n\r\n");
        assert(req.method == "GET");
        assert(req.uri == "/hoge");
        assert(req.minorVer == 1);
        assert(req.headers.length == 2);
        assert(req.headers[0] == Header("Host", "example.com"));
        assert(req.headers[1] == Header("Cookie", ""));
    }

    // multibyte included
    {
        auto req = parse("GET /hoge HTTP/1.1\r\nHost: example.com\r\nUser-Agent: \343\201\262\343/1.0\r\n\r\n");
        assert(req.method == "GET");
        assert(req.uri == "/hoge");
        assert(req.minorVer == 1);
        assert(req.headers.length == 2);
        assert(req.headers[0] == Header("Host", "example.com"));
        assert(req.headers[1] == Header("User-Agent", "\343\201\262\343/1.0"));
    }

    //multiline
    {
        auto req = parse("GET / HTTP/1.0\r\nfoo: \r\nfoo: b\r\n  \tc\r\n\r\n");
        assert(req.method == "GET");
        assert(req.uri == "/");
        assert(req.minorVer == 0);
        assert(req.headers.length == 3);
        assert(req.headers[0] == Header("foo", ""));
        assert(req.headers[1] == Header("foo", "b"));
        assert(req.headers[2] == Header(null, "  \tc"));
    }

    // header name with trailing space
    parse("GET / HTTP/1.0\r\nfoo : ab\r\n\r\n", Test.err);

    // incomplete
    assert(parse("\r", Test.partial).method == null);
    assert(parse("\r\n", Test.partial).method == null);
    assert(parse("\r\nGET", Test.partial).method == null);
    assert(parse("GET", Test.partial).method == null);
    assert(parse("GET ", Test.partial).method == "GET");
    assert(parse("GET /", Test.partial).uri == null);
    assert(parse("GET / ", Test.partial).uri == "/");
    assert(parse("GET / HTTP/1.1", Test.partial).minorVer == 0);
    assert(parse("GET / HTTP/1.1\r", Test.partial).minorVer == 1);
    assert(parse("GET / HTTP/1.1\r\n", Test.partial).minorVer == 1);
    parse("GET / HTTP/1.0\r\n\r", Test.partial);
    parse("GET / HTTP/1.0\r\n\r\n", Test.complete);
    parse(" / HTTP/1.0\r\n\r\n", Test.err); // empty method
    parse("GET  HTTP/1.0\r\n\r\n", Test.err); // empty request target
    parse("GET / \r\n\r\n", Test.err); // empty version
    parse("GET / HTTP/1.0\r\n:a\r\n\r\n", Test.err); // empty header name
    parse("GET / HTTP/1.0\r\n :a\r\n\r\n", Test.err); // empty header name (space only)
    parse("G\0T / HTTP/1.0\r\n\r\n", Test.err); // NUL in method
    parse("G\tT / HTTP/1.0\r\n\r\n", Test.err); // tab in method
    parse("GET /\x7f HTTP/1.0\r\n\r\n", Test.err); // DEL in uri
    parse("GET / HTTP/1.0\r\na\0b: c\r\n\r\n", Test.err); // NUL in header name
    parse("GET / HTTP/1.0\r\nab: c\0d\r\n\r\n", Test.err); // NUL in header value
    parse("GET / HTTP/1.0\r\na\033b: c\r\n\r\n", Test.err); // CTL in header name
    parse("GET / HTTP/1.0\r\nab: c\033\r\n\r\n", Test.err); // CTL in header value
    parse("GET / HTTP/1.0\r\n/: 1\r\n\r\n", Test.err); // invalid char in header value
    parse("GET   /   HTTP/1.0\r\n\r\n", Test.complete); // multiple spaces between tokens

    // accept MSB chars
    {
        auto res = parse("GET /\xa0 HTTP/1.0\r\nh: c\xa2y\r\n\r\n");
        assert(res.method == "GET");
        assert(res.uri == "/\xa0");
        assert(res.minorVer == 0);
        assert(res.headers.length == 1);
        assert(res.headers[0] == Header("h", "c\xa2y"));
    }

    parse("GET / HTTP/1.0\r\n\x7b: 1\r\n\r\n", Test.err); // disallow '{'

    // exclude leading and trailing spaces in header value
    {
        auto req = parse("GET / HTTP/1.0\r\nfoo:  a \t \r\n\r\n");
        assert(req.headers[0].value == "a");
    }

    // leave the body intact
    parse("GET / HTTP/1.0\r\n\r\nfoo bar baz", Test.complete, "foo bar baz".length);

    // realworld
    {
        auto req = parse("GET /cookies HTTP/1.1\r\nHost: 127.0.0.1:8090\r\nConnection: keep-alive\r\nCache-Control: max-age=0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nUser-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.56 Safari/537.17\r\nAccept-Encoding: gzip,deflate,sdch\r\nAccept-Language: en-US,en;q=0.8\r\nAccept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3\r\nCookie: name=wookie\r\n\r\n");
        assert(req.method == "GET");
        assert(req.uri == "/cookies");
        assert(req.minorVer == 1);
        assert(req.headers[0] == Header("Host", "127.0.0.1:8090"));
        assert(req.headers[1] == Header("Connection", "keep-alive"));
        assert(req.headers[2] == Header("Cache-Control", "max-age=0"));
        assert(req.headers[3] == Header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"));
        assert(req.headers[4] == Header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.56 Safari/537.17"));
        assert(req.headers[5] == Header("Accept-Encoding", "gzip,deflate,sdch"));
        assert(req.headers[6] == Header("Accept-Language", "en-US,en;q=0.8"));
        assert(req.headers[7] == Header("Accept-Charset", "ISO-8859-1,utf-8;q=0.7,*;q=0.3"));
        assert(req.headers[8] == Header("Cookie", "name=wookie"));
    }

    // newline
    {
        auto req = parse("GET / HTTP/1.0\nfoo: a\n\n");
    }
}

@("Response")
// Tests from https://github.com/h2o/picohttpparser/blob/master/test.c
unittest
{
    auto parse(string data, Test test = Test.complete, int additional = 0)
    {
        auto handler = new HttpRequestParserHandler;
        auto parser =  new HttpMessageParser(handler);

        auto res = parser.parseResponse(data);
        // if (res < 0) writeln("Err: ", cast(ParserError)(-res));
        final switch (test)
        {
            case Test.err: assert(res < -ParserError.partial); break;
            case Test.partial: assert(res == -ParserError.partial); break;
            case Test.complete: assert(res == data.length - additional); break;
        }

        return handler;
    }

    // simple
    {
        auto res = parse("HTTP/1.0 200 OK\r\n\r\n");
        assert(res.headers.length == 0);
        assert(res.status == 200);
        assert(res.minorVer == 0);
        assert(res.statusMsg == "OK");
    }

    parse("HTTP/1.0 200 OK\r\n\r", Test.partial); // partial

    // parse headers
    {
        auto res = parse("HTTP/1.1 200 OK\r\nHost: example.com\r\nCookie: \r\n\r\n");
        assert(res.headers.length == 2);
        assert(res.minorVer == 1);
        assert(res.status == 200);
        assert(res.statusMsg == "OK");
        assert(res.headers[0] == Header("Host", "example.com"));
        assert(res.headers[1] == Header("Cookie", ""));
    }

    // parse multiline
    {
        auto res = parse("HTTP/1.0 200 OK\r\nfoo: \r\nfoo: b\r\n  \tc\r\n\r\n");
        assert(res.headers.length == 3);
        assert(res.minorVer == 0);
        assert(res.status == 200);
        assert(res.statusMsg == "OK");
        assert(res.headers[0] == Header("foo", ""));
        assert(res.headers[1] == Header("foo", "b"));
        assert(res.headers[2] == Header(null, "  \tc"));
    }

    // internal server error
    {
        auto res = parse("HTTP/1.0 500 Internal Server Error\r\n\r\n");
        assert(res.headers.length == 0);
        assert(res.minorVer == 0);
        assert(res.status == 500);
        assert(res.statusMsg == "Internal Server Error");
    }

    parse("H", Test.partial); // incomplete 1
    parse("HTTP/1.", Test.partial); // incomplete 2
    assert(parse("HTTP/1.1", Test.partial).minorVer == 0); // incomplete 3 - differs from picohttpparser as we don't parse exact version
    assert(parse("HTTP/1.1 ", Test.partial).minorVer == 1); // incomplete 4
    parse("HTTP/1.1 2", Test.partial); // incomplete 5
    assert(parse("HTTP/1.1 200", Test.partial).status == 0); // incomplete 6
    assert(parse("HTTP/1.1 200 ", Test.partial).status == 200); // incomplete 7
    assert(parse("HTTP/1.1 200\r", Test.partial).status == 200); // incomplete 7.1
    parse("HTTP/1.1 200 O", Test.partial); // incomplete 8
    assert(parse("HTTP/1.1 200 OK\r", Test.partial).statusMsg == "OK"); // incomplete 9 - differs from picohttpparser
    assert(parse("HTTP/1.1 200 OK\r\n", Test.partial).statusMsg == "OK"); // incomplete 10
    assert(parse("HTTP/1.1 200 OK\n", Test.partial).statusMsg == "OK"); // incomplete 11
    assert(parse("HTTP/1.1 200 OK\r\nA: 1\r", Test.partial).headers.length == 0); // incomplete 11
    parse("HTTP/1.1   200   OK\r\n\r\n", Test.complete); // multiple spaces between tokens

    // incomplete 12
    {
        auto res = parse("HTTP/1.1 200 OK\r\nA: 1\r\n", Test.partial);
        assert(res.headers.length == 1);
        assert(res.headers[0] == Header("A", "1"));
    }

    // slowloris (incomplete)
    {
        auto parser =  new HttpMessageParser(new HttpRequestParserHandler);
        assert(parser.parseResponse("HTTP/1.0 200 OK\r\n") == -ParserError.partial);
        assert(parser.parseResponse("HTTP/1.0 200 OK\r\n\r") == -ParserError.partial);
        assert(parser.parseResponse("HTTP/1.0 200 OK\r\n\r\nblabla") == "HTTP/1.0 200 OK\r\n\r\n".length);
    }

    parse("HTTP/1. 200 OK\r\n\r\n", Test.err); // invalid http version
    parse("HTTP/1.2z 200 OK\r\n\r\n", Test.err); // invalid http version 2
    parse("HTTP/1.1  OK\r\n\r\n", Test.err); // no status code

    assert(parse("HTTP/1.1 200\r\n\r\n").statusMsg == ""); // accept missing trailing whitespace in status-line
    parse("HTTP/1.1 200X\r\n\r\n", Test.err); // garbage after status 1
    parse("HTTP/1.1 200X \r\n\r\n", Test.err); // garbage after status 2
    parse("HTTP/1.1 200X OK\r\n\r\n", Test.err); // garbage after status 3

    assert(parse("HTTP/1.1 200 OK\r\nbar: \t b\t \t\r\n\r\n").headers[0].value == "b"); // exclude leading and trailing spaces in header value
}

@("Incremental")
unittest
{
    string req = "GET /cookies HTTP/1.1\r\nHost: 127.0.0.1:8090\r\nConnection: keep-alive\r\nCache-Control: max-age=0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nUser-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.56 Safari/537.17\r\nAccept-Encoding: gzip,deflate,sdch\r\nAccept-Language: en-US,en;q=0.8\r\nAccept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3\r\nCookie: name=wookie\r\n\r\n";
    auto handler = new HttpRequestParserHandler;
    auto parser =  new HttpMessageParser(handler);
    uint parsed;
    auto res = parser.parseRequest(req[0.."GET /cookies HTTP/1.1\r\nHost: 127.0.0.1:8090\r\nConn".length], parsed);
    assert(res == -ParserError.partial);
    assert(handler.method == "GET");
    assert(handler.uri == "/cookies");
    assert(handler.minorVer == 1);
    assert(handler.headers.length == 1);
    assert(handler.headers[0] == Header("Host", "127.0.0.1:8090"));

    res = parser.parseRequest(req, parsed);
    assert(res == req.length);
    assert(handler.method == "GET");
    assert(handler.uri == "/cookies");
    assert(handler.minorVer == 1);
    assert(handler.headers[0] == Header("Host", "127.0.0.1:8090"));
    assert(handler.headers[1] == Header("Connection", "keep-alive"));
    assert(handler.headers[2] == Header("Cache-Control", "max-age=0"));
    assert(handler.headers[3] == Header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"));
    assert(handler.headers[4] == Header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.56 Safari/537.17"));
    assert(handler.headers[5] == Header("Accept-Encoding", "gzip,deflate,sdch"));
    assert(handler.headers[6] == Header("Accept-Language", "en-US,en;q=0.8"));
    assert(handler.headers[7] == Header("Accept-Charset", "ISO-8859-1,utf-8;q=0.7,*;q=0.3"));
    assert(handler.headers[8] == Header("Cookie", "name=wookie"));
}
