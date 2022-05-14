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

module archttp.codec.HttpEncoder;

import geario.codec.Encoder;

import nbuff;

import archttp.HttpRequest;
import archttp.HttpResponse;

class HttpEncoder : Encoder!HttpResponse
{
    override NbuffChunk Encode(HttpResponse response)
    {
        return NbuffChunk(response.ToBuffer());
    }
}
