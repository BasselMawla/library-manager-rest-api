// routes/books_controller.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert' show jsonDecode, jsonEncode;
import '../models/books_model.dart' as booksModel;

// Books Collection Routes
class BooksController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) {
      return Response.ok('BoooksController returned');
    });

    // Add a book
    // TODO: auth and allow adding multiple copies
    // TODO: Add delete ?and update?
    router.post('/', (Request request) async {
      final bookJson = await request.readAsString();
      Map<String, dynamic> bookMap = jsonDecode(bookJson);

      booksModel.addBook(bookMap);

      return Response.ok(jsonEncode(bookMap));
    });
    return router;
  }
}
