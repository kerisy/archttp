
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

    app.Get("/cookie", (request, response) {
        response.cookie("username", "myuser");
        response.cookie(new Cookie("token", "0123456789"));
        response.send("Set cookies ..");
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
