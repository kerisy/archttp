# Archttp
Archttp 是一个简单好用，拥有真正高性能的 Web 框架。

## 漂亮的示例代码
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

## 命名规则说明：
Archttp 类的方法名都是大写字母开头的驼峰式命名规则，因为“get”、“delete”都是D语言的保留关键字。
其他类的方法名都是小写字母开头的驼峰式命名规则。

## 项目依赖
 * [Geario](https://github.com/kerisy/geario)
 * [Nbuff](https://github.com/ikod/nbuff)
 * [httparsed](https://github.com/tchaloupka/httparsed)
 * [urld](https://github.com/dhasenan/urld)

## 感谢贡献者
 * zoujiaqing
 * Heromyth
 * ikod
 * tchaloupka
 * dhasenan
