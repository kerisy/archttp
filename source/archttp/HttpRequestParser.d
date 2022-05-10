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

module archttp.HttpRequestParser;

import archttp.HttpRequest;
import archttp.HttpMessageParser;
import archttp.MultiPart;
import archttp.HttpRequestParserHandler;

import std.conv : to;
import std.array : split;
import std.string : indexOf, stripRight;
import std.algorithm : startsWith;
import std.regex : regex, matchAll;
import std.file : write, isDir, isFile, mkdir, mkdirRecurse, FileException;

import std.stdio : writeln;

enum ParserStatus : ushort {
    READY = 1,
    PARTIAL,
    COMPLETED,
    FAILED
}

class HttpRequestParser
{
    private
    {
        string _data;

        long _parsedLength = 0;
        ParserStatus _parserStatus;

        bool _headerParsed = false;

        HttpRequestParserHandler _headerHandler;
        HttpMessageParser _headerParser;

        HttpRequest _request;

        string _contentType;
        long _contentLength = 0;

        string _fileUploadTempPath = "./tmp";
    }

    this()
    {
        _headerHandler = new HttpRequestParserHandler;
        _headerParser = new HttpMessageParser(_headerHandler);

        _parserStatus = ParserStatus.READY;
    }

    ParserStatus parserStatus()
    {
        return _parserStatus;
    }

    ulong parse(string data)
    {
        _data = data;

        if (_headerParsed == false && !parseHeader())
        {
            return 0;
        }

        // var for paring content
        _contentType = _request.header("Content-Type");

        string contentLengthString = _request.header("Content-Length");
        if (contentLengthString.length > 0)
            _contentLength = contentLengthString.to!long;

        if (_contentLength > 0)
        {
            if (!parseBody())
            {
                return 0;
            }
        }

        _parserStatus = ParserStatus.COMPLETED;
        
        return _parsedLength;
    }

    private bool parseHeader()
    {
        auto result = _headerParser.parseRequest(_data);
        if (result < 0)
        {
            if (result == -1)
            {
                _parserStatus = ParserStatus.PARTIAL;
                return false;
            }

            _parserStatus = ParserStatus.FAILED;
            return false;
        }

        _request = _headerHandler.request();
        // _headerHandler.reset();
        _parsedLength = result;
        _headerParsed = true;

        return true;
    }

    private bool parseBody()
    {
        if (_data.length < _parsedLength + _contentLength)
        {
            writeln(_data.length, " - ", _parsedLength, " - ", _contentLength);
            return false;
        }

        if (_contentType.startsWith("application/json") || _contentType.startsWith("text/"))
        {
            _request.body(_data[_parsedLength.._parsedLength + _contentLength]);
            _parsedLength += _contentLength;
            return true;
        }
        
        if (_contentType.startsWith("application/x-www-form-urlencoded"))
        {
            if (!parseFormFields())
                return false;

            return true;
        }

        if (_contentType.startsWith("multipart/form-data"))
        {
            if (!parseMultipart())
                return false;
        }

        return true;
    }

    private bool parseFormFields()
    {
        foreach (fieldStr; _data[_parsedLength.._parsedLength + _contentLength].split("&"))
        {
            auto s = fieldStr.indexOf("=");
            if (s > 0)
                _request.fields[fieldStr[0..s]] = fieldStr[s+1..fieldStr.length];
        }

        _parsedLength += _contentLength;

        return true;
    }

    private bool parseMultipart()
    {
        string boundary = "--" ~ getBoundary();

        while (true)
        {
            bool isFile = false;

            long boundaryIndex = _data[_parsedLength .. $].indexOf(boundary);
            if (boundaryIndex == -1)
                break;

            boundaryIndex += _parsedLength;

            long boundaryEndIndex = boundaryIndex + boundary.length + 2; // boundary length + "--" length + "\r\n" length
            if (boundaryEndIndex + 2 == _data.length && _data[boundaryIndex .. boundaryEndIndex] == boundary ~ "--")
            {
                writeln("parse done");
                _parserStatus = ParserStatus.COMPLETED;
                _parsedLength = boundaryIndex + boundary.length + 2 + 2;
                break;
            }

            long ignoreBoundaryIndex = boundaryIndex + boundary.length + 2;

            long nextBoundaryIndex = _data[ignoreBoundaryIndex .. $].indexOf(boundary);

            if (nextBoundaryIndex == -1)
            {
                // not last boundary? parse error?
                writeln("not last boundary? parse error?");
                break;
            }

            nextBoundaryIndex += ignoreBoundaryIndex;

            long contentIndex = _data[ignoreBoundaryIndex .. nextBoundaryIndex].indexOf("\r\n\r\n");
            if (contentIndex == -1)
            {
                break;
            }
            contentIndex += ignoreBoundaryIndex + 4;

            string headerData = _data[ignoreBoundaryIndex .. contentIndex-4];
            MultiPart part;

            foreach (headerContent ; headerData.split("\r\n"))
            {
                long i = headerContent.indexOf(":");
                string headerKey = headerContent[0..i];
                string headerValue = headerContent[i..headerContent.length];
                if (headerKey != "Content-Disposition")
                {
                    part.headers[headerKey] = headerValue;

                    continue;
                }

                // for part.name
                string nameValuePrefix = "name=\"";
                long nameIndex = headerValue.indexOf(nameValuePrefix);
                if (nameIndex == -1)
                    continue;

                long nameValueIndex = nameIndex + nameValuePrefix.length;
                long nameEndIndex = nameValueIndex + headerValue[nameValueIndex..$].indexOf("\"");
                part.name = headerValue[nameValueIndex..nameEndIndex];

                // for part.filename
                string filenameValuePrefix = "filename=\"";
                long filenameIndex = headerValue.indexOf(filenameValuePrefix);
                if (filenameIndex >= 0)
                {
                    isFile = true;

                    long filenameValueIndex = filenameIndex + filenameValuePrefix.length;
                    long filenameEndIndex = filenameValueIndex + headerValue[filenameValueIndex..$].indexOf("\"");
                    part.filename = headerValue[filenameValueIndex..filenameEndIndex];
                }
            }

            long contentSize = nextBoundaryIndex-2-contentIndex;
            if (isFile)
            {
                if (!part.filename.length == 0)
                {
                    part.filesize = contentSize;
                    // TODO: FreeBSD / macOS / Linux or Windows?
                    string dirSeparator = "/";
                    version (Windows)
                    {
                        dirSeparator = "\\";
                    }

                    if (!isDir(_fileUploadTempPath))
                    {
                        try
                        {
                            mkdir(_fileUploadTempPath);
                        }
                        catch (FileException e)
                        {
                            writeln("mkdir error: ", e);
                            // throw e;
                        }
                    }
                    
                    string filepath = stripRight(_fileUploadTempPath, dirSeparator) ~ dirSeparator ~ part.filename;
                    part.filepath = filepath;
                    try
                    {
                        write(filepath, _data[contentIndex..nextBoundaryIndex-2]);
                    }
                    catch (FileException e)
                    {
                            writeln("file write error: ", e);
                    }

                    _request.files ~= part;
                }
            }
            else
            {
                _request.fields[part.name] = _data[contentIndex..nextBoundaryIndex-2];
            }

            _parsedLength = nextBoundaryIndex;
        }

        return true;
    }

    private string getBoundary()
    {
        string searchString = "boundary=";
        long index = _contentType.indexOf(searchString);
        if (index == -1)
            return "";

        return _contentType[index+searchString.length.._contentType.length];
    }

    private void extractCookies()
    {
        // QByteArrayList temp(headerField.values(HTTP::COOKIE));
        // int size = temp.size();
        // for(int i = 0; i < size; ++i)
        // {
        //     const QByteArray &txt = temp[i].replace(";", ";\n");;
        //     QList<QNetworkCookie> cookiesList = QNetworkCookie::parseCookies(txt);
        //     for(QNetworkCookie &cookie : cookiesList)
        //     {
        //         if(cookie.name() == HTTP::SESSION_ID)
        //             sessionId = cookie.value();
        //         cookies.push_back(std::move(cookie));
        //     }
        // }
    }

    HttpRequest request()
    {
        return _request;
    }

    void reset()
    {
        _contentLength = 0;
        _request = null;
        _headerParsed = false;
        _parserStatus = ParserStatus.READY;
        _data = "";
        _contentType = "";
    }
}
