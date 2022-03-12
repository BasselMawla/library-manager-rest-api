// models/books_model.dart

import 'dart:convert';
import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import '../database_connection.dart' as database;

// TODO: Rewrite to new standards
addBook(Map<String, dynamic> book, String librarianId) async {
  if (!isValidInput(book)) {
    // Guard statement, return error/fail
    // TODO
  }

  MySqlConnection dbConnection = await database.createConnection();

  // Insert the book
  // TODO: try catch
  Results result = await dbConnection.query(
      'INSERT INTO book (book_id, isbn, title, author, dewey_number, librarian_id, added_on) ' +
          'VALUE (UUID(), ?, ?, ?, ?, ?, now())',
      [
        book['isbn'],
        book['title'],
        book['author'],
        book['dewey_number'],
        librarianId,
      ]);
  print('Book added. Affected rows: ${result.affectedRows}');

  dbConnection.close();
  return Response.ok("Book added.");
}

Future<Response> getBookStockList() async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection.query(
        'SELECT DISTINCT(isbn), COUNT(isbn) as stock FROM book GROUP BY isbn LIMIT 25');

    Map<String, dynamic> books = Map<String, dynamic>();

    int i = 1;
    for (var row in results) {
      books[i.toString()] = row.fields;
      i++;
    }

    return Response.ok(jsonEncode(books), headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    });
  } catch (e) {
    print(e);
    return Response.internalServerError(
        body: 'Something went wrong on our end. Please try again later.');
  } finally {
    dbConnection.close();
  }
}

bool isValidInput(Map<String, dynamic> book) {
  // TODO
  return false;
}
