module main;

import archttp.HttpRequestParser;
import archttp.Router;
import archttp.HttpRequest;

import std.stdio;
import std.conv : to;
import std.file : readText;

void parseTest0()
{
    string data = `POST /login?action=check HTTP/1.1
Host: localhost:8080
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:99.0) Gecko/20100101 Firefox/99.0
Accept: */*
Accept-Language: zh-CN,en-US;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate, br
Content-Type: multipart/form-data; boundary=---------------------------332604924416206460511787781889
Content-Length: 697
Connection: keep-alive
Sec-Fetch-Dest: empty
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin

`;
    data ~= "-----------------------------332604924416206460511787781889\r\nContent-Disposition: form-data; name=\"username\"\r\n\r\nzoujiaqing\r\n-----------------------------332604924416206460511787781889\r\nContent-Disposition: form-data; name=\"avatar\"; filename=\"a.jpg\"\r\nContent-Type: image/jpeg\r\n\r\nthis is a avatar.\r\n-----------------------------332604924416206460511787781889\r\nContent-Disposition: form-data; name=\"file[]\"; filename=\"url.d\"\r\nContent-Type: application/octet-stream\r\n\r\n/* hello world */\r\n-----------------------------332604924416206460511787781889\r\nContent-Disposition: form-data; name=\"file[]\"; filename=\"a.jpg\"\r\nContent-Type: image/jpeg\r\n\r\nthis is a pic.\r\n-----------------------------332604924416206460511787781889--\r\n";

    // data = readText("./reqeustdata");

    auto parser = new HttpRequestParser;

    long result = parser.parse(data);

    writeln("data length: ", data.length);
    writeln("parsed data: ", result);

    auto request = parser.request();

    parser.reset();

    OnRequest(request);
}

void parseTest1()
{

    string[] buf;
    buf ~= `P`;
    buf ~= `OST /login?action=check HTTP/1.1
Host: localhost:8080`;
    buf ~= `
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:99.0) Gecko/20100101 Firefox/99.0
Accept: */*
Accept-Language: zh-CN,en-US;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate, br
Content-Type: multipart/form-data; boundary=---------------------------332604924416206460511787781889
Content-Length: 697
Connection: keep-alive
Sec-Fetch-Dest: empty`;
    buf ~= `
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin

`;
    buf ~= "-----------------------------3326049244162064";
    buf ~= "60511787781889\r\nContent-Disposition: form-data; name=\"username\"\r\n\r\nzouji";
    buf ~= "aqing\r\n-----------------------------332604924416206460511787781889\r\nContent-Disposi";
    buf ~= "tion: form-data; name=\"avatar\"; filename=\"a.jpg\"\r\nContent-Type: image/jpeg\r\n\r\nth";
    buf ~= "is is a avatar.\r\n-----------------------------332604924416206460511787781889\r\nContent-Disposit";
    buf ~= "ion: form-data; name=\"file[]\"; filename=\"url.d\"\r\nContent-Type: application/octet-stre";
    buf ~= "am\r\n\r\n/* hello world */\r\n-----------------------------332604924416206460511787781";
    buf ~= "889\r\nContent-Disposition: form-data; name=\"file[]\"; filename=\"a.jpg\"\r\nContent-T";
    buf ~= "ype: image/jpeg\r\n\r\nthis is a pic.\r\n-----------------------------3326";
    buf ~= "04924416206460511787781889--\r\n";

    auto parser = new HttpRequestParser;

    string data = "";

    foreach ( b ; buf)
    {
        data ~= b;
        ulong result = parser.parse(data);
        
        if (parser.parserStatus() == ParserStatus.PARTIAL)
        {
                continue;
        }

        if (parser.parserStatus() == ParserStatus.COMPLETED)
        {
            auto request = parser.request();

            parser.reset();

            OnRequest(request);
        }

        if (parser.parserStatus() == ParserStatus.FAILED)
        {
            writeln("Parsing error!");
            break;
        }
    }

    writeln("Request end.");
}

void OnRequest(HttpRequest request)
{
    writeln(request.path());
    writeln(request.method());
    
    writeln("\nHeaders:");
    foreach ( name, value ; request.headers() )
    {
        writeln(name, " - ", value);
    }

    writeln("\nfields:");
    writeln(request.fields);

    writeln("\nfiles:");
    writeln(request.files);
}

void main()
{
    parseTest1();
}
