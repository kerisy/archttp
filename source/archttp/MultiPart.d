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

module archttp.MultiPart;

struct MultiPart
{
    string[string] headers;
    string name;
    string value;
    string filename;
    long filesize = 0;
    string filepath;
}
