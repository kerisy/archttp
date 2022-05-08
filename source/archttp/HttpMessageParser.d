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

module archttp.HttpMessageParser;

nothrow @nogc:

/// Parser error codes
enum ParserError : int
{
    partial = 1,    /// not enough data to parse message
    newLine,        /// invalid character in new line
    headerName,     /// invalid character in header name
    headerValue,    /// invalid header value
    status,         /// invalid character in response status
    token,          /// invalid character in token
    noHeaderName,   /// empty header name
    noMethod,       /// no method in request line
    noVersion,      /// no version in request line / response status line
    noUri,          /// no URI in request line
    noStatus,       /// no status code or text in status line
    invalidMethod,  /// invalid method in request line
    invalidVersion, /// invalid version for the protocol message
}

struct HttpRequestHeader
{
    const(char)[] name;
    const(char)[] value;
}

interface HttpMessageHandler
{
    void onMethod(const(char)[] method);
    void onUri(const(char)[] uri);
    int onVersion(const(char)[] ver);
    void onHeader(const(char)[] name, const(char)[] value);
    void onStatus(int status);
    void onStatusMsg(const(char)[] statusMsg);
}

/**
 *  HTTP/RTSP message parser.
 */
class HttpMessageParser
{
    import std.traits : ForeachType, isArray, Unqual;

    this(HttpMessageHandler handler)
    {
        this._messageHandler = handler;
    }

    /**
     *  Parses message request (request line + headers).
     *
     *  Params:
     *    - buffer = buffer to parse message from
     *    - lastPos = optional argument to store / pass previous position to which message was
     *                already parsed (speeds up parsing when message comes in parts)
     *
     *  Returns:
     *    * parsed message header length when parsed sucessfully
     *    * `-ParserError` on error (ie. -1 when message header is not complete yet)
     */
    long parseRequest(T)(T buffer, ref ulong lastPos)
        if (isArray!T && (is(Unqual!(ForeachType!T) == char) || is(Unqual!(ForeachType!T) == ubyte)))
    {
        static if (is(Unqual!(ForeachType!T) == char)) return parse!parseRequestLine(cast(const(ubyte)[])buffer, lastPos);
        else return parse!parseRequestLine(buffer, lastPos);
    }

    /// ditto
    long parseRequest(T)(T buffer)
        if (isArray!T && (is(Unqual!(ForeachType!T) == char) || is(Unqual!(ForeachType!T) == ubyte)))
    {
        ulong lastPos;
        static if (is(Unqual!(ForeachType!T) == char)) return parse!parseRequestLine(cast(const(ubyte)[])buffer, lastPos);
        else return parse!parseRequestLine(buffer, lastPos);
    }

    /**
     *  Parses message response (status line + headers).
     *
     *  Params:
     *    - buffer = buffer to parse message from
     *    - lastPos = optional argument to store / pass previous position to which message was
     *                already parsed (speeds up parsing when message comes in parts)
     *
     *  Returns:
     *    * parsed message header length when parsed sucessfully
     *    * `-ParserError.partial` on error (ie. -1 when message header is not comlete yet)
     */
    long parseResponse(T)(T buffer, ref ulong lastPos)
        if (isArray!T && (is(Unqual!(ForeachType!T) == char) || is(Unqual!(ForeachType!T) == ubyte)))
    {
        static if (is(Unqual!(ForeachType!T) == char)) return parse!parseStatusLine(cast(const(ubyte)[])buffer, lastPos);
        else return parse!parseStatusLine(buffer, lastPos);
    }

    /// ditto
    int parseResponse(T)(T buffer)
        if (isArray!T && (is(Unqual!(ForeachType!T) == char) || is(Unqual!(ForeachType!T) == ubyte)))
    {
        ulong lastPos;
        static if (is(Unqual!(ForeachType!T) == char)) return parse!parseStatusLine(cast(const(ubyte)[])buffer, lastPos);
        else return parse!parseStatusLine(buffer, lastPos);
    }

    /// Gets provided structure used during parsing
    HttpMessageHandler messageHandler() { return _messageHandler; }

private:

    // character map of valid characters for token, forbidden:
    //   0-SP, DEL, HT
    //   ()<>@,;:\"/[]?={}
    enum tokenRanges = "\0 \"\"(),,//:@[]{}\x7f\xff";
    enum tokenSSERanges = "\0 \"\"(),,//:@[]{\xff"; // merge of last range due to the SSE register size limit

    enum versionRanges = "\0-:@[`{\xff"; // allow only [A-Za-z./] characters

    HttpMessageHandler _messageHandler;

    long parse(alias pred)(const(ubyte)[] buffer, ref ulong lastPos)
    {
        assert(buffer.length >= lastPos);
        immutable l = buffer.length;

        if (_expect(!lastPos, true))
        {
            if (_expect(!buffer.length, false)) return err(ParserError.partial);

            // skip first empty line (some clients add CRLF after POST content)
            if (_expect(buffer[0] == '\r', false))
            {
                if (_expect(buffer.length == 1, false)) return err(ParserError.partial);
                if (_expect(buffer[1] != '\n', false)) return err(ParserError.newLine);
                lastPos += 2;
                buffer = buffer[lastPos..$];
            }
            else if (_expect(buffer[0] == '\n', false))
                buffer = buffer[++lastPos..$];

            immutable res = pred(buffer);
            if (_expect(res < 0, false)) return res;

            lastPos = cast(int)(l - buffer.length); // store index of last parsed line
        }
        else buffer = buffer[lastPos..$]; // skip already parsed lines

        immutable hdrRes = parseHeaders(buffer);
        lastPos = cast(int)(l - buffer.length); // store index of last parsed line

        if (_expect(hdrRes < 0, false)) return hdrRes;
        return lastPos; // finished
    }

    int parseHeaders(ref const(ubyte)[] buffer)
    {
        bool hasHeader;
        size_t start, i;
        const(ubyte)[] name, value;
        while (true)
        {
            // check for msg headers end
            if (_expect(buffer.length == 0, false)) return err(ParserError.partial);
            if (buffer[0] == '\r')
            {
                if (_expect(buffer.length == 1, false)) return err(ParserError.partial);
                if (_expect(buffer[1] != '\n', false)) return err(ParserError.newLine);

                buffer = buffer[2..$];
                return 0;
            }
            if (_expect(buffer[0] == '\n', false))
            {
                buffer = buffer[1..$];
                return 0;
            }

            if (!hasHeader || (buffer[i] != ' ' && buffer[i] != '\t'))
            {
                auto ret = parseToken!(tokenRanges, ':', tokenSSERanges)(buffer, i);
                if (_expect(ret < 0, false)) return ret;
                if (_expect(start == i, false)) return err(ParserError.noHeaderName);
                name = buffer[start..i]; // store header name
                i++; // move index after colon

                // skip over SP and HT
                for (;; ++i)
                {
                    if (_expect(i == buffer.length, false)) return err(ParserError.partial);
                    if (buffer[i] != ' ' && buffer[i] != '\t') break;
                }
                start = i;
            }
            else name = null; // multiline header

            // parse value
            auto ret = parseToken!("\0\010\012\037\177\177", "\r\n")(buffer, i);
            if (_expect(ret < 0, false)) return ret;
            value = buffer[start..i];
            mixin(advanceNewline);
            hasHeader = true; // flag to define that we can now accept multiline header values

            // remove trailing SPs and HTABs
            if (_expect(value.length && (value[$-1] == ' ' || value[$-1] == '\t'), false))
            {
                int j = cast(int)value.length - 2;
                for (; j >= 0; --j)
                    if (!(value[j] == ' ' || value[j] == '\t'))
                        break;
                value = value[0..j+1];
            }

            static if (is(typeof(_messageHandler.onHeader("", "")) == void))
                _messageHandler.onHeader(cast(const(char)[])name, cast(const(char)[])value);
            else {
                auto r = _messageHandler.onHeader(cast(const(char)[])name, cast(const(char)[])value);
                if (_expect(r < 0, false)) return r;
            }

            // header line completed -> advance buffer
            buffer = buffer[i..$];
            start = i = 0;
        }
        assert(0);
    }

    auto parseRequestLine(ref const(ubyte)[] buffer)
    {
        size_t start, i;

        // METHOD
        auto ret = parseToken!(tokenRanges, ' ', tokenSSERanges)(buffer, i);
        if (_expect(ret < 0, false)) return ret;
        if (_expect(start == i, false)) return err(ParserError.noMethod);

        static if (is(typeof(_messageHandler.onMethod("")) == void))
            _messageHandler.onMethod(cast(const(char)[])buffer[start..i]);
        else {
            auto r = _messageHandler.onMethod(cast(const(char)[])buffer[start..i]);
            if (_expect(r < 0, false)) return r;
        }
        
        mixin(skipSpaces!(ParserError.noUri));
        start = i;

        // PATH
        ret = parseToken!("\000\040\177\177", ' ')(buffer, i);
        if (_expect(ret < 0, false)) return ret;

        static if (is(typeof(_messageHandler.onUri("")) == void))
            _messageHandler.onUri(cast(const(char)[])buffer[start..i]);
        else {
            auto ur = _messageHandler.onUri(cast(const(char)[])buffer[start..i]);
            if (_expect(ur < 0, false)) return ur;
        }
        
        mixin(skipSpaces!(ParserError.noVersion));
        start = i;

        // VERSION
        ret = parseToken!(versionRanges, "\r\n")(buffer, i);
        if (_expect(ret < 0, false)) return ret;

        static if (is(typeof(_messageHandler.onVersion("")) == void))
            _messageHandler.onVersion(cast(const(char)[])buffer[start..i]);
        else {
            auto vr = _messageHandler.onVersion(cast(const(char)[])buffer[start..i]);
            if (_expect(vr < 0, false)) return vr;
        }

        mixin(advanceNewline);

        // advance buffer after the request line
        buffer = buffer[i..$];
        return 0;
    }

    auto parseStatusLine(ref const(ubyte)[] buffer)
    {
        size_t start, i;

        // VERSION
        auto ret = parseToken!(versionRanges, ' ')(buffer, i);
        if (_expect(ret < 0, false)) return ret;
        if (_expect(start == i, false)) return err(ParserError.noVersion);

        static if (is(typeof(_messageHandler.onVersion("")) == void))
            _messageHandler.onVersion(cast(const(char)[])buffer[start..i]);
        else {
            auto r = _messageHandler.onVersion(cast(const(char)[])buffer[start..i]);
            if (_expect(r < 0, false)) return r;
        }

        mixin(skipSpaces!(ParserError.noStatus));
        start = i;

        // STATUS CODE
        if (_expect(i+3 >= buffer.length, false))
            return err(ParserError.partial); // not enough data - we want at least [:digit:][:digit:][:digit:]<other char> to try to parse

        int code;
        foreach (j, m; [100, 10, 1])
        {
            if (buffer[i+j] < '0' || buffer[i+j] > '9') return err(ParserError.status);
            code += (buffer[start+j] - '0') * m;
        }
        i += 3;

        static if (is(typeof(_messageHandler.onStatus(code)) == void))
            _messageHandler.onStatus(code);
        else {
            auto sr = _messageHandler.onStatus(code);
            if (_expect(sr < 0, false)) return sr;
        }

        if (_expect(i == buffer.length, false))
            return err(ParserError.partial);
        if (_expect(buffer[i] != ' ' && buffer[i] != '\r' && buffer[i] != '\n', false))
            return err(ParserError.status); // Garbage after status

        start = i;

        // MESSAGE
        ret = parseToken!("\0\010\012\037\177\177", "\r\n")(buffer, i);
        if (_expect(ret < 0, false)) return ret;

        // remove preceding space (we did't advance over spaces because possibly missing status message)
        if (i > start)
        {
            while (buffer[start] == ' ' && start < i) start++;
            if (i > start)
            {
                static if (is(typeof(_messageHandler.onStatusMsg("")) == void))
                    _messageHandler.onStatusMsg(cast(const(char)[])buffer[start..i]);
                else {
                    auto smr = _messageHandler.onStatusMsg(cast(const(char)[])buffer[start..i]);
                    if (_expect(smr < 0, false)) return smr;
                }
            }
        }

        mixin(advanceNewline);

        // advance buffer after the status line
        buffer = buffer[i..$];
        return 0;
    }

    /*
     * Advances buffer over the token to the next character while checking for valid characters.
     * On success, buffer index is left on the next character.
     *
     * Params:
     *      - ranges = ranges of characters to stop on
     *      - sseRanges = if null, same ranges is used, but they are limited to 8 ranges
     *      - next  = next character/s to stop on (must be present in the provided ranges too)
     * Returns: 0 on success error code otherwise
     */
    int parseToken(string ranges, alias next, string sseRanges = null)(const(ubyte)[] buffer, ref size_t i) pure
    {
        version (DigitalMars) {
            static if (__VERSION__ >= 2094) pragma(inline, true); // older compilers can't inline this
        } else pragma(inline, true);

        immutable charMap = parseTokenCharMap!(ranges)();

        static if (LDC_with_SSE42)
        {
            // CT function to prepare input for SIMD vector enum
            static byte[16] padRanges()(string ranges)
            {
                byte[16] res;
                // res[0..ranges.length] = cast(byte[])ranges[]; - broken on macOS betterC tests
                foreach (i, c; ranges) res[i] = cast(byte)c;
                return res;
            }

            static if (sseRanges) alias usedRng = sseRanges;
            else alias usedRng = ranges;
            static assert(usedRng.length <= 16, "Ranges must be at most 16 characters long");
            static assert(usedRng.length % 2 == 0, "Ranges must have even number of characters");
            enum rangesSize = usedRng.length;
            enum byte16 rngE = padRanges(usedRng);

            if (_expect(buffer.length - i >= 16, true))
            {
                size_t left = (buffer.length - i) & ~15; // round down to multiple of 16
                byte16 ranges16 = rngE;

                do
                {
                    byte16 b16 = () @trusted { return cast(byte16)_mm_loadu_si128(cast(__m128i*)&buffer[i]); }();
                    immutable r = _mm_cmpestri(
                        ranges16, rangesSize,
                        b16, 16,
                        _SIDD_LEAST_SIGNIFICANT | _SIDD_CMP_RANGES | _SIDD_UBYTE_OPS
                    );

                    if (r != 16)
                    {
                        i += r;
                        goto FOUND;
                    }
                    i += 16;
                    left -= 16;
                }
                while (_expect(left != 0, true));
            }
        }
        else
        {
            // faster unrolled loop to iterate over 8 characters
            loop: while (_expect(buffer.length - i >= 8, true))
            {
                static foreach (_; 0..8)
                {
                    if (_expect(!charMap[buffer[i]], false)) goto FOUND;
                    ++i;
                }
            }
        }

        // handle the rest
        if (_expect(i >= buffer.length, false)) return err(ParserError.partial);

        FOUND:
        while (true)
        {
            static if (is(typeof(next) == char)) {
                static assert(!charMap[next], "Next character is not in ranges");
                if (buffer[i] == next) return 0;
            } else {
                static assert(next.length > 0, "Next character not provided");
                static foreach (c; next) {
                    static assert(!charMap[c], "Next character is not in ranges");
                    if (buffer[i] == c) return 0;
                }
            }
            if (_expect(!charMap[buffer[i]], false)) return err(ParserError.token);
            if (_expect(++i == buffer.length, false)) return err(ParserError.partial);
        }
    }

    // advances over new line
    enum advanceNewline = q{
            assert(i < buffer.length);
            if (_expect(buffer[i] == '\r', true))
            {
                if (_expect(i+1 == buffer.length, false)) return err(ParserError.partial);
                if (_expect(buffer[i+1] != '\n', false)) return err(ParserError.newLine);
                i += 2;
            }
            else if (buffer[i] == '\n') ++i;
            else assert(0);
        };

    // skips over spaces in the buffer
    template skipSpaces(ParserError err)
    {
        enum skipSpaces = `
            do {
                ++i;
                if (_expect(buffer.length == i, false)) return err(ParserError.partial);
                if (_expect(buffer[i] == '\r' || buffer[i] == '\n', false)) return err(` ~ err.stringof ~ `);
            } while (buffer[i] == ' ');
        `;
    }
}

/**
 * Parses HTTP version from a slice returned in `onVersion` callback.
 *
 * Returns: minor version (0 for HTTP/1.0 or 1 for HTTP/1.1) on success or
 *          `-ParserError.invalidVersion` on error
 */
int parseHttpVersion(const(char)[] ver) pure
{
    if (_expect(ver.length != 8, false)) return err(ParserError.invalidVersion);

    static foreach (i, c; "HTTP/1.")
        if (_expect(ver[i] != c, false)) return err(ParserError.invalidVersion);

    if (_expect(ver[7] < '0' || ver[7] > '9', false)) return err(ParserError.invalidVersion);
    
    return ver[7] - '0';
}

private:

int err(ParserError e) pure { pragma(inline, true); return -(cast(int)e); }

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

immutable(bool[256]) parseTokenCharMap(string invalidRanges)() {
    static immutable charMap = buildValidCharMap(invalidRanges);
    return charMap;
}

//** used intrinsics **//

version(LDC)
{
    public import core.simd;
    public import ldc.intrinsics;
    import ldc.gccbuiltins_x86;

    enum LDC_with_SSE42 = __traits(targetHasFeature, "sse4.2");

    // These specify the type of data that we're comparing.
    enum _SIDD_UBYTE_OPS            = 0x00;
    enum _SIDD_UWORD_OPS            = 0x01;
    enum _SIDD_SBYTE_OPS            = 0x02;
    enum _SIDD_SWORD_OPS            = 0x03;

    // These specify the type of comparison operation.
    enum _SIDD_CMP_EQUAL_ANY        = 0x00;
    enum _SIDD_CMP_RANGES           = 0x04;
    enum _SIDD_CMP_EQUAL_EACH       = 0x08;
    enum _SIDD_CMP_EQUAL_ORDERED    = 0x0c;

    // These are used in _mm_cmpXstri() to specify the return.
    enum _SIDD_LEAST_SIGNIFICANT    = 0x00;
    enum _SIDD_MOST_SIGNIFICANT     = 0x40;

    // These macros are used in _mm_cmpXstri() to specify the return.
    enum _SIDD_BIT_MASK             = 0x00;
    enum _SIDD_UNIT_MASK            = 0x40;

    // some definition aliases to commonly used names
    alias __m128i = int4;

    // some used methods aliases
    alias _expect = llvm_expect;
    alias _mm_loadu_si128 = loadUnaligned!__m128i;
    alias _mm_cmpestri = __builtin_ia32_pcmpestri128;
}
else
{
    enum LDC_with_SSE42 = false;

    T _expect(T)(T val, T expected_val) if (__traits(isIntegral, T))
    {
        pragma(inline, true);
        return val;
    }
}

pragma(msg, "SSE: ", LDC_with_SSE42);
