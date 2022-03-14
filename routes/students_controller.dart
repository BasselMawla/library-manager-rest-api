// routes/students_controller.dart

import 'dart:convert';

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

    // TODO: Regex username
    router.get('/<username>', (Request request, String username) async {
      // Check if librarian or student's own account
      final jwtAuth = request.context['jwtAuth'] as JWT;
      final accountId = jwtAuth.subject;
      final loggedInUsername = await getUsernameFromId(accountId);
      final isLoggedInLibrarian = await isLibrarian(accountId);

      // Not logged in as librarian or same username
      if (loggedInUsername != username && !isLoggedInLibrarian) {
        return Response.forbidden('Not allowed.');
      }

      return StudentsModel.getStudent(username);
    });

    // Librarians can lend a book to a student
    router.post('/<username>', (Request request, String username) async {
      // Check if librarian
      final jwtAuth = request.context['jwtAuth'] as JWT;
      final accountId = jwtAuth.subject;
      final isAllowed = await isLibrarian(accountId);
      if (!isAllowed) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      // Retrieve book UUID to add from JSON
      final requestBody = await request.readAsString();
      try {
        final Map<String, dynamic> bookInfo = jsonDecode(requestBody);

        // Check that UUID exists
        if (isMissingInput([bookInfo['uuid']])) {
          return Response(400, body: "Please enter book UUID.");
        }
        return StudentsModel.borrowBook(
            await getIdFromUsername(username), bookInfo['uuid']);
      } on FormatException catch (e) {
        print(e);
        return Response(400, body: "Invalid JSON!");
      }
    });

    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    return handler;
  }
}
