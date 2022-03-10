// route_handler.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'routes/books_controller.dart';
import 'routes/students_controller.dart';

// Routing setup
class RouteHandler {
  Handler get handler {
    final router = Router();

    router.mount('/students', StudentsController().router);
    router.mount('/books', BooksController().router);
    //router.mount('/accounts', AccountsController().router);

    // All invalid URLs
    router.all('/<ignored|.*>',
        (Request request) => Response.notFound('Page Not Found!'));

    return router;
  }
}
