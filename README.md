# Archttp
A highly performant web framework written in D.

# Example for web server
```D

import archttp;

void main()
{
    uint ioThreads = 1;
    uint workerThreads = 128;

    auto app = new Archttp(ioThreads, workerThreads);

    app.Bind(8080);

    app.Get("/", (context) {
        auto response = context.response();
        response.body("Hello Archttp");
    });

    app.Get("/json", (context) {
        import std.json;

        auto response = context.response();
        auto j = JSONValue( ["message" : "Hello, World!"] );
        
        response.json(j);
    });

    app.Get("/user/{id:\\d+}", (context) {
        auto request = context.request();
        auto response = context.response();
        response.body("User id: " ~ request.parameters["id"]);
    });

    app.Get("/blog/{name}", (context) {
        auto request = context.request();
        auto response = context.response();
        response.body("Username: " ~ request.parameters["name"]);
    });

    app.Post("/upload", (context) {
        auto response = context.response();
        response.body("Using post method!");
    });

    app.Run();
}

```