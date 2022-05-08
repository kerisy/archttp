
import archttp;

void main()
{
    auto server = new HttpServer;
    server.Listen(8080);

    server.Get("/", (HttpContext httpContext) {
        httpContext.response().body("Hello archttp ;)");
        httpContext.Send(httpContext.response().ToBuffer());
    });

    server.Get("/world", (HttpContext httpContext) {
        httpContext.response().body("Hello world");
        httpContext.Send(httpContext.response().ToBuffer());
    });

    server.Get("/user/{id:\\d+}", (HttpContext httpContext) {
        httpContext.response().body("User id: " ~ httpContext.request.parameters["id"]);
        httpContext.Send(httpContext.response().ToBuffer());
    });

    server.Get("/blog/{name}", (HttpContext httpContext) {
        httpContext.response().body("Username: " ~ httpContext.request.parameters["name"]);
        httpContext.Send(httpContext.response().ToBuffer());
    });

    server.Post("/upload", (HttpContext httpContext) {
        httpContext.response().body("Using post method!");
        httpContext.Send(httpContext.response().ToBuffer());
    });

    server.Start();
}
