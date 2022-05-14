# Archttp
Archttp 是一个简单好用，拥有真正高性能的 Web 框架。

## 漂亮的示例代码
```D

import archttp;

void main()
{
    auto app = new Archttp;

    app.Bind(8080);

    app.Get("/", (ctx) {
        auto response = ctx.response();
        response.body("Hello Archttp");
    });

    app.Get("/json", (ctx) {
        import std.json;

        auto response = ctx.response();
        auto j = JSONValue( ["message" : "Hello, World!"] );
        
        response.json(j);
    });

    app.Get("/user/{id:\\d+}", (ctx) {
        auto request = ctx.request();
        auto response = ctx.response();
        response.body("User id: " ~ request.parameters["id"]);
    });

    app.Get("/blog/{name}", (ctx) {
        auto request = ctx.request();
        auto response = ctx.response();
        response.body("Username: " ~ request.parameters["name"]);
    });

    app.Post("/upload", (ctx) {
        auto response = ctx.response();
        response.body("Using post method!");
    });

    app.Run();
}

```

## 项目依赖
 * [Nbuff](https://github.com/ikod/nbuff)
 * [httparsed](https://github.com/tchaloupka/httparsed)

## 感谢贡献者
 * zoujiaqing
 * Heromyth
 * ikod
 * tchaloupka
