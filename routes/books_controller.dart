// routes/books_controller.dart

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
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

    router.get('/', (Request request) async {
      // Check that a librarian is logged in
      final jwtAuth = request.context['jwtAuth'] as JWT;
      final accountId = jwtAuth.subject;
      final isAllowed = await isLibrarian(accountId);
      if (!isAllowed) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      return await booksModel.getBookStockList();
    });

    // Add a book
    // TODO: auth and allow adding multiple copies
    // TODO: Add delete ?and update?
    router.post('/', (Request request) async {
      // Check that a librarian is logged in
      final jwtAuth = request.context['jwtAuth'] as JWT;
      final accountId = jwtAuth.subject;
      final isAllowed = await isLibrarian(accountId);
      if (!isAllowed) {
        return Response.forbidden('Not allowed! Must be a librarian.');
      }

      final requestBody = await request.readAsString();
      Map<String, dynamic> book = jsonDecode(requestBody);

      // TODO: First check that all data needed is included
      // quantity should be between 1-10
      if (book['quantity'] == null || book['quantity'] < 1) {
        book['quantity'] = 1;
      }
      return await booksModel.addBook(book, accountId);
    });

    // Authorize librarians only
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    return handler;
  }
}
