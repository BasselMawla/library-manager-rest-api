// routes/books_controller.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'dart:convert' show jsonDecode, jsonEncode;

import '../models/books_model.dart' as BooksModel;
import '../models/utils.dart'; // for the utf8.encode method

// Books Collection Routes
class BooksController {
  Handler get handler {
    final router = Router();

    // Get all books and their stock or search for a book
    router.get('/', (Request request) async {
      // First check if this is a search request
      String searchQuery = request.url.queryParameters['q'];
      if (searchQuery != null && !searchQuery.isEmpty) {
        // Search query found
        return BooksModel.searchBooks(searchQuery);
      }

      // Not a search query, retrieve all books and their stocks
      return await BooksModel.getBookStockList();
    });

    // Add a book
    router.post('/', (Request request) async {
      // Check that a librarian is logged in
      if (!await isLibrarian(request)) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      final requestBody = await request.readAsString();
      Map<String, dynamic> book = jsonDecode(requestBody);

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
        return Response.forbidden(
            jsonEncode({'error': 'Not allowed! Must be a librarian.'}));
      }

      return BooksModel.returnBook(uuid);
    });

    // Authorize librarians only
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    return handler;
  }
}
