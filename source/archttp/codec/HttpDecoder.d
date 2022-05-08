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

module archttp.codec.HttpDecoder;

import gear.codec.Decoder;
import gear.codec.Encoder;
import gear.buffer.Buffer;
import gear.buffer.Bytes;

import gear.event;

import archttp.HttpRequestParser;
import archttp.HttpRequest;
import archttp.HttpContext;

import gear.logging;

class HttpDecoder : Decoder!HttpRequest
{
    private
    {
        HttpRequestParser _parser = new HttpRequestParser;
        HttpRequest _request;
    }
    
    override long Decode(ref Buffer buffer, ref HttpRequest request)
    {
        long result = _parser.parse(cast(string) buffer.Data().data());
        
        if ( ParserStatus.COMPLETED == _parser.parserStatus() )
        {
            request = _parser.request();

            _parser.reset();
            buffer.Pop(result);
            
            return result;
        }

        if ( ParserStatus.PARTIAL == _parser.parserStatus() )
        {
            return 0;
        }
        
        return -1;
    }
}
