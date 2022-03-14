// routes/books_controller.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'dart:convert' show jsonDecode;

import '../models/books_model.dart' as BooksModel;
import '../models/utils.dart'; // for the utf8.encode method

// Books Collection Routes
class BooksController {
  Handler get handler {
    final router = Router();

    // Get all books and their stock
    router.get('/', (Request request) async {
      // Check that a librarian is logged in
      if (!await isLibrarian(request)) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      return await BooksModel.getBookStockList();
    });

    // Add a book
    router.post('/', (Request request) async {
      // TODO: auth and allow adding multiple copies
      // TODO: Add delete ?and update?
      // Check that a librarian is logged in
      if (!await isLibrarian(request)) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      final requestBody = await request.readAsString();
      Map<String, dynamic> book = jsonDecode(requestBody);

      // TODO: First check that all data needed is included
      // quantity should be between 1-10
      if (book['quantity'] == null || book['quantity'] < 1) {
        book['quantity'] = 1;
      }
      return await BooksModel.addBook(book, getIdFromJwt(request));
    });

    // Return a book
    router.post('/<uuid>', (Request request, String uuid) async {
      // Check that a librarian is logged in
      if (!await isLibrarian(request)) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      return BooksModel.returnBook(uuid);
    });

    // Authorize librarians only
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    return handler;
  }
}
