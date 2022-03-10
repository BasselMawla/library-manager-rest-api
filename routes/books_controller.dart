// routes/books_controller.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert' show jsonDecode, JsonEncoder;
import '../models/books_model.dart' as booksModel;

import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method

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
      final requestBody = await request.readAsString();
      Map<String, dynamic> book = jsonDecode(requestBody);
      // TODO: First check that all data needed is included
      booksModel.addBook(book);

      // TODO: Just return a success message, no need to display the book
      // Using JsonEncoder to make the JSON human readable
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');

      return Response.ok(encoder.convert(book));
    });
    return router;
  }
}
