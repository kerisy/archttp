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

module archttp.codec.HttpCodec;

import geario.codec.Codec;
import geario.codec.Encoder;
import geario.codec.Decoder;

import archttp.codec.HttpDecoder;
import archttp.codec.HttpEncoder;

import archttp.HttpRequest;
import archttp.HttpResponse;

/** 
 * 
 */
class HttpCodec : Codec!(HttpRequest, HttpResponse)
{
    private
    {
        HttpEncoder _encoder;
        HttpDecoder _decoder;
    }

    this()
    {
        _decoder = new HttpDecoder();
        _encoder = new HttpEncoder();
    }

    override Decoder!HttpRequest decoder()
    {
        return _decoder;
    }

    override Encoder!HttpResponse encoder()
    {
        return _encoder;
    }
}
