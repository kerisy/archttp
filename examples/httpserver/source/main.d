
import archttp;

void main()
{
    uint ioThreads = 1;
    uint workerThreads = 128;

    auto app = new Archttp(ioThreads, workerThreads);

    app.Bind(8080);

    app.Get("/", (context) {
        return context.response().body("Hello archttp ;)");
    });

    app.Get("/world", (context) {
        return context.response().body("Hello world");
    });

    app.Get("/user/{id:\\d+}", (context) {
        return context.response().body("User id: " ~ context.request.parameters["id"]);
    });

    app.Get("/blog/{name}", (context) {
        return context.response().body("Username: " ~ context.request.parameters["name"]);
    });

    app.Post("/upload", (context) {
        return context.response().body("Using post method!");
    });

    app.Run();
}
