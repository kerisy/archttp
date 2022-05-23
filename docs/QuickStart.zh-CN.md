## Archttp 简介
Archttp 是使用 D语言编写的 web 服务端框架，拥有 Golang 的并发能力。Archttp 拥有类似 ExpressJS 的 API 设计，所以易用性极强。

### Archttp 核心关注的指标有三个：
 1. 简单
 2. 灵活
 3. 性能

## 文档目录
- [快速入门](#QUICK_START)
- [路由](#ROUTING)
- [路由组](#ROUTER_GROUP)
- [中间件](#MIDDLEWARE)
- [Cookie](#COOKIE)
- [向客户端发送文件](#SEND_FILES)
- [上传文件](#UPLOAD_FILES)

<span id="ROUTING"></span>
### Archttp 快速开始示例
首先我们使用 dub 命令创建 example 示例代码，在命令行输入 `dub init example` 然后选择 `sdl` 格式配置，接下来一路回车，在 Adding dependency 的时候输入 `archttp`，这时候 dub 包管理器会为你添加好 `archttp` 的版本依赖，具体如下：
```bash
% dub init example
Package recipe format (sdl/json) [json]: sdl
Name [example]: 
Description [A minimal D application.]: 
Author name [zoujiaqing]: 
License [proprietary]: 
Copyright string [Copyright © 2022, zoujiaqing]: 
Add dependency (leave empty to skip) []: archttp
Adding dependency archttp ~>1.0.0
Add dependency (leave empty to skip) []: 
Successfully created an empty project in '/Users/zoujiaqing/projects/example'.
Package successfully created in example
```
这时候我们可以看到生成了一个目录为 `example` 的 D语言项目，编辑项目目录打开 `source/app.d` 编辑代码为下面的实例代码：
```D
import archttp;

void main()
{
    auto app = new Archttp;

    app.get("/", (req, res) {
        res.send("Hello, World!");
    });

    app.listen(8080);
}
```
保存好代码后我们进入 `example/` 目录下执行编译命令 `dub build` 等待编译结果：
```bash
dub build
Fetching archttp 1.0.0 (getting selected version)...
...
Linking...
To force a rebuild of up-to-date targets, run again with --force.
```
从上面的命令输出可以看出来 `dub` 帮我们下载了 `archttp 1.0.0` 并且进行了项目编译，最后的 `Linking...` 也没有出错，我们可以运行项目了。
```bash
 % ./example
2022-May-22 23:05:42.945314 | 18102067 | Info | Archttp.run | io threads: 8 | ../../.dub/packages/archttp-1.0.0/archttp/source/archttp/Archttp.d:222
 ```
项目已经跑起来了，启用了 8 个 io 线程，代码中监听了 8080 端口，浏览器访问 `http://localhost:8080/` 会输出 `Hello, World!` 字符串。

<span id="QUICK_START"></span>
### 路由功能示例代码
```D
import archttp;

void main()
{
    auto app = new Archttp;

    app.get("/", (req, res) {
        res.send("Hello, World!");
    });

    app.get("/user/{id:\\d+}", (req, res) {
        res.send("User id: " ~ req.params["id"]);
    });

    app.get("/blog/{name}", (req, res) {
        res.send("Username: " ~ req.params["name"]);
    });

    app.listen(8080);
}
```

可以看出 Archttp 的路由功能非常简单清晰，也支持正则匹配和取值。

<span id="ROUTING"></span>
### 路由组挂载绑定
```D
import archttp;

void main()
{
    auto app = new Archttp;

    app.get("/", (req, res) {
        res.send("Front page!");
    });

    auto adminRouter = Archttp.newRouter();
    
    adminRouter.get("/", (req, res) {
        res.send("Hello, Admin!");
    });

    adminRouter.get("/login", (req, res) {
        res.send("Login page!");
    });

    app.use("/admin", adminRouter);

    app.listen(8080);
}
```

可以看出 adminRouter 相当于一个路由组（路由组的概念来自于 Hunt Framework），路由组可以使用自己的中间件规则，也就是他相当于一个独立的子应用，可以独立控制权限等。

<span id="MIDDLEWARE"></span>
### 中间件使用示例代码
```java
import archttp;

import std.stdio : writeln;

void main()
{
    auto app = new Archttp;

    app.use((req, res, next) {
        writeln("middleware 1 ..");
        next();
    });

    app.use((req, res, next) {
        writeln("middleware 2 ..");
        next();
    });

    app.use((req, res, next) {
        writeln("middleware 3 ..");
        next();
    });

    app.use((req, es, next) {
        writeln("middleware 4 ..");
    });

    app.use((req, res, next) {
        writeln("middleware 5 ..");
    });

    app.get("/", (req, res) {
        res.send("Hello, World!");
    });

    app.listen(8080);
}
```

这段代码运行之后可以发现没有执行到 middleware 5，现在 Archttp 的执行遵循洋葱规则。

<span id="COOKIE"></span>
### Cookie 使用示例代码
```java
import archttp;

import std.stdio : writeln;

void main()
{
    auto app = new Archttp;

    app.get("/", (request, response) {

        writeln(request.cookie("token"));
        writeln(request.cookies());

        response.cookie("username", "myuser");
        response.cookie("token", "0123456789");

        response.send("Set cookies ..");
    });

    app.listen(8080);
}
```

<span id="SEND_FILES"></span>
### 向客户端发送文件示例代码

```D
import archttp;

void main()
{
    auto app = new Archttp;

    app.get("/download", (req, res) {
        res.sendFile("./attachments/avatar.jpg");
    });

    app.listen(8080);
}
```

<span id="UPLOAD_FILES"></span>
## 社区与交流群
Github讨论区：https://github.com/kerisy/archttp
D语言中文社区：https://dlangchina.com
QQ群：184183224
