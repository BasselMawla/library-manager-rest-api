// routes/students_controller.dart

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/students_model.dart' as StudentsModel;
import '../models/utils.dart';

// Students Collection Routes
class StudentsController {
  Handler get handler {
    final router = Router();

    // Get all students and their borrow count
    router.get('/', (Request request) async {
      // Check that a librarian is logged in
      if (!await isLibrarian(request)) {
        return Response.forbidden(
          jsonEncode({'error': 'Not allowed! Must be a librarian.'}),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      return await StudentsModel.getAllStudents();
    });

    // Get student and record
    router.get('/<username>', (Request request, String username) async {
      // Check if librarian or student's own account
      final accountId = getIdFromJwt(request);
      final loggedInUsername = await getUsernameFromId(accountId);
      final isLoggedInLibrarian = await isLibrarian(request);

      // Not logged in as librarian or same username
      if (loggedInUsername != username && !isLoggedInLibrarian) {
        return Response.forbidden('Not allowed.');
      }

      return StudentsModel.getStudent(username);
    });

    // Lend a book to a student
    router.post('/<username>', (Request request, String username) async {
      // Check if librarian
      if (!await isLibrarian(request)) {
        return Response.forbidden(
          jsonEncode({'error': 'Not allowed! Must be a librarian.'}),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      // Retrieve book UUID to add from JSON
      final requestBody = await request.readAsString();
      try {
        final Map<String, dynamic> bookInfo = jsonDecode(requestBody);

        // Check that UUID exists
        if (isMissingInput([bookInfo['uuid']])) {
          return Response(
            400,
            body: jsonEncode({'error': 'Please enter book UUID.'}),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
        return StudentsModel.borrowBook(
            await getIdFromUsername(username), bookInfo['uuid']);
      } on FormatException catch (e) {
        print(e);
        return Response(
          400,
          body: jsonEncode({'error': 'Invalid JSON!'}),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }
    });

    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    return handler;
  }
}
