// routes/students_controller.dart

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/students_model.dart' as StudentsModel;
import '../models/utils.dart';

// Students Collection Routes
class StudentsController {
  Handler get handler {
    final router = Router();

    router.get('/', (Request request) async {
      // Check that a librarian is logged in
      final jwtAuth = request.context['jwtAuth'] as JWT;
      final accountId = jwtAuth.subject;
      final isAllowed = await isLibrarian(accountId);
      if (!isAllowed) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      return await StudentsModel.getAllStudents();
    });

    // TODO: Authorize librarians only for get all.
    // Allow any user view their borrowing record.
    // Probably using /records.
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    return handler;
  }
}
