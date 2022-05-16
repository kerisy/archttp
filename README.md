# Archttp
A highly performant web framework written in D.

## Example for web server
```D

import archttp;

void main()
{
    auto app = new Archttp;

    app.Get("/", (request, response) {
        response.send("Hello, World!");
    });

    app.Get("/json", (request, response) {
        import std.json;
        response.send( JSONValue( ["message" : "Hello, World!"] ) );
    });

    app.Get("/user/{id:\\d+}", (request, response) {
        response.send("User id: " ~ request.params["id"]);
    });

    app.Get("/blog/{name}", (request, response) {
        response.send("Username: " ~ request.params["name"]);
    });

    app.Get("/upload", (request, response) {
        response.send("Using post method!");
    });

    app.Listen(8080);
}

```

## Note on naming rules:
The method names of Archttp classe are all humped with a capital letter, because "get" and "delete" are reserved keywords for D.
All other classes have camel - case names that begin with a lowercase letter.

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
