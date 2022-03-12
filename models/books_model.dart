// models/books_model.dart

import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import '../database_connection.dart' as database;

// TODO: Rewrite to new standards
addBook(Map<String, dynamic> book) async {
  if (!isValidInput(book)) {
    // Guard statement, return error/fail
    // TODO
  }

  MySqlConnection dbConnection = await database.createConnection();

  // Insert the book
  // TODO: try catch
  Results result = await dbConnection.query(
      'INSERT INTO book (book_id, isbn, title, author, dewey_number, added_on) ' +
          'VALUE (UUID(), ?, ?, ?, ?, now())',
      [
        book['isbn'],
        book['title'],
        book['author'],
        book['dewey_number'],
      ]);
  print('Book added. Affected rows: ${result.affectedRows}');

  dbConnection.close();
  return Response.ok("Book added.");
}

Future<Response> getBooks() async {}

bool isValidInput(Map<String, dynamic> book) {
  // TODO
  return false;
}
