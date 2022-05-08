
import archttp;

void main()
{
    auto server = new HttpServer;
    server.Listen(8080);

    server.Get("/", (context) {
        return context.response().body("Hello archttp ;)");
    });

    server.Get("/world", (context) {
        return context.response().body("Hello world");
    });

    server.Get("/user/{id:\\d+}", (context) {
        return context.response().body("User id: " ~ context.request.parameters["id"]);
    });

    server.Get("/blog/{name}", (context) {
        return context.response().body("Username: " ~ context.request.parameters["name"]);
    });

    server.Post("/upload", (context) {
        return context.response().body("Using post method!");
    });

    server.Start();
}
