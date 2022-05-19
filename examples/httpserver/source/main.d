
import archttp;
import std.stdio;

void main()
{
    auto app = new Archttp;

    app.use((request, response, next) {
        writeln("middleware 1 ..");
        next();
    });

    app.use((request, response, next) {
        writeln("middleware 2 ..");
        next();
    });

    app.use((request, response, next) {
        writeln("middleware 3 ..");
        next();
    });

    app.use((request, response, next) {
        writeln("middleware 4 ..");
    });

    app.use((request, response, next) {
        writeln("middleware 5 ..");
    });

    app.get("/", (request, response) {
        response.send("Hello, World!");
    });

    auto adminRouter = app.createRouter();
    
    adminRouter.add("/", HttpMethod.GET, (request, response) {
        response.send("Hello, Admin!");
    });

    adminRouter.add("/login", HttpMethod.GET, (request, response) {
        response.send("Login page!");
    });

    app.use("/admin", adminRouter);

    app.get("/json", (request, response) {
        import std.json;
        response.send( JSONValue( ["message" : "Hello, World!"] ) );
    });

    app.get("/download", (request, response) {
        response.sendFile("./attachments/avatar.jpg");
    });

    app.get("/cookie", (request, response) {

        writeln(request.cookie("token"));
        writeln(request.cookies());

        response.cookie("username", "myuser");
        response.cookie(new Cookie("token", "0123456789"));
        response.cookie(new Cookie("userid", "123"));
        response.send("Set cookies ..");
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

    app.listen(8080);
}
