// routes/students_controller.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// Students Collection Routes
class StudentsController {
  Router get router {
    final router = Router();

    router.get("/", (Request request) {
      return Response.ok("StudentsController returned");
    });

    // POST test route
    router.post("/", (Request request) async {
      final body = await request.readAsString();
      print(body);
      return Response.ok(body);
    });
    return router;
  }
}
