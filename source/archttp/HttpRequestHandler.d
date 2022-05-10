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

module archttp.HttpRequestHandler;

public import archttp.HttpContext;
public import archttp.HttpResponse;
public import archttp.HttpRequest;

alias void delegate(HttpContext httpContext) HttpRequestHandler;
