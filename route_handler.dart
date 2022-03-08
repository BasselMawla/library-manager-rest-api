// route_handler.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// Routing setup
class RouteHandler {
  Handler get handler {
    final router = Router();

    // GET test route
    router.get("/books", (Request request) {
      return Response.ok("Book returned");
    });

    // POST test route
    router.post("/students", (Request request) async {
      final body = await request.readAsString();
      print(body);
      return Response.ok(body);
    });

    // All invalid URLs
    router.all("/<ignored|.*>", (Request request) {
      return Response.notFound("Page Not Found!");
    });

    return router;
  }
}
