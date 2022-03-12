// routes/books_controller.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert' show jsonDecode, JsonEncoder;
import '../models/books_model.dart' as booksModel;

import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/utils.dart'; // for the utf8.encode method

// Books Collection Routes
class BooksController {
  Handler get handler {
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

      return booksModel.addBook(book);
    });

    // Authorize librarians only
    final handler =
        Pipeline().addMiddleware(authLibrarians()).addHandler(router);

    return handler;
  }
}
