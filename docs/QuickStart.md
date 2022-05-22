## Archttp
Archttp is a Web server framework written in D language with Golang concurrency capability. Archttp has an ExpressJS-like API design, which makes it extremely easy to use.

### Archttp's core focus is on three metrics:
1. Simple
2. Flexible
3. Performance

## Document directory
- Quick Start
- the routing
- Routing group
- middleware
- Cookie
- Sends files to the client
- Upload files
### Archttp base sample compiled and run
First, use the dub command to create the example code. On the command line, type 'dub init example' and select 'sdl'. Next, press Enter and type 'archttp' under Adding Dependency. The duB package manager will add a version dependency for 'archTTp' as follows:
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

Add this sample code to `example/source/app.d`

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

After saving the code, run the dub build command in the 'example/' directory and wait for the result:

```bash
dub build
Fetching archttp 1.0.0 (getting selected version)...
...
Linking...
To force a rebuild of up-to-date targets, run again with --force.
```

'dub' downloaded 'archttp 1.0.0' and compiled the project. 'No error, we can run the project.
```bash
% ./example
2022 - May - 22 23:05:42. 945314 | 18102067 | Info | Archttp. Run | IO threads: 8 |.. /.. /. Dub/packages/archttp - 1.0.0 archttp/source/archttp archttp. D: 222
```

The project is up and running, with eight IO threads enabled, listening on port 8080 in the code, and the browser accessing 'http://localhost:8080/' outputs' Hello, World! 'string.

### Route function example code
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

It can be seen that the routing function of Archttp is very simple and clear. It also supports regular matching and value selection.

### Route bind group bind
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

AdminRouter acts as a routing group (a concept derived from the Hunt Framework), which can use its own middleware rules, i.e. it acts as a separate subapplication with independent control over permissions, etc.

### Middleware uses sample code
```D
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

After running this code, you can see that middleware 5 is not executed, and Archttp is now executed according to onion rules.

### Cookie use sample code
```D
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

Send sample file code to the client

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

## Community and Communication groups
Github discussion: https://github.com/kerisy/archttp
D Language Chinese community: https://dlangchina.com
QQ group: 184183224
