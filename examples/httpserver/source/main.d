
import archttp;
import std.stdio;
void main()
{
    auto app = new Archttp;

    app.get("/", (request, response) {
        response.send("Hello, World!");
    });

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
