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

import gear.codec.Encoder;

import gear.buffer.Buffer;

import archttp.HttpRequest;
import archttp.HttpResponse;

class HttpEncoder : Encoder!HttpResponse
{
    override Buffer Encode(HttpResponse response)
    {
        return Buffer(cast(string) response.ToBuffer());
    }
}
