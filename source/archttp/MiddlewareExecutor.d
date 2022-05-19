module archttp.MiddlewareExecutor;

import archttp.HttpRequestHandler;
import archttp.HttpRequest;
import archttp.HttpResponse;

struct MiddlewareExecutor
{
    HttpRequest request;
    HttpResponse response;
    HttpRequestMiddlewareHandler[] middlewareHandlers;
    uint currentMiddlewareIndex;
    HttpRequestMiddlewareHandler currentMiddlewareHandler;

    this(HttpRequest request, HttpResponse response, HttpRequestMiddlewareHandler[] handlers)
    {
        this.request = request;
        this.response = response;
        this.middlewareHandlers = handlers;
    }

    void execute()
    {
        if (middlewareHandlers.length == 0)
            return;

        currentMiddlewareIndex = 0;
        currentMiddlewareHandler = middlewareHandlers[0];

        currentMiddlewareHandler(request, response, &next);
    }

    void next()
    {
        currentMiddlewareIndex++;
        if (currentMiddlewareIndex == middlewareHandlers.length)
            return;
        
        currentMiddlewareHandler = middlewareHandlers[currentMiddlewareIndex];
        currentMiddlewareHandler(request, response, &next);
    }

}