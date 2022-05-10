
import archttp;

void main()
{
    uint ioThreads = 1;
    uint workerThreads = 128;

    auto app = new Archttp(ioThreads, workerThreads);

    app.Bind(8080);

    app.Get("/textplain", (context) {
        auto response = context.response();
        response.body("Hello Archttp");
    });

    app.Get("/json", (context) {
        import std.json;

        auto response = context.response();
        auto j = JSONValue( ["message" : "Hello, World!"] );

        response.json(j);
    });

    app.Run();
}
