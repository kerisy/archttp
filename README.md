# Archttp
A highly performant web framework written in D.

## Documents
 1. [Quick Start](docs/QuickStart.md)
 2. [快速开始](docs/QuickStart.zh-CN.md)

## Example for web server
```D

import archttp;

void main()
{
    auto app = new Archttp;

    app.get("/", (request, response) {
        response.send("Hello, World!");
    });

    app.get("/user/{id:\\d+}", (request, response) {
        response.send("User id: " ~ request.params["id"]);
    });

    app.get("/blog/{name}", (request, response) {
        response.send("Username: " ~ request.params["name"]);
    });

    app.post("/upload", (request, response) {
        response.send("Using post method!");
    });

    app.get("/download", (request, response) {
        response.sendFile("./attachments/avatar.jpg");
    });

    app.get("/json", (request, response) {
        import std.json;
        response.send( JSONValue( ["message" : "Hello, World!"] ) );
    });

    app.get("/cookie", (request, response) {

        import std.stdio : writeln;

        writeln(request.cookie("token"));
        writeln(request.cookies());

        response.cookie("username", "myuser");
        response.cookie(new Cookie("token", "0123456789"));
        response.send("Set cookies ..");
    });

    app.listen(8080);
}
```

## Dependencies
 * [Geario](https://github.com/kerisy/geario)
 * [Nbuff](https://github.com/ikod/nbuff)
 * [httparsed](https://github.com/tchaloupka/httparsed)
 * [urld](https://github.com/dhasenan/urld)

## Thanks contributors
 * zoujiaqing
 * Heromyth
 * ikod
 * tchaloupka
 * dhasenan
