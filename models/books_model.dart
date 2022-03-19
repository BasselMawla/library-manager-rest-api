// models/books_model.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import '../database_connection.dart' as database;
import 'utils.dart';

// TODO: Rewrite to new standards
Future<Response> addBook(Map<String, dynamic> book, String librarianId) async {
  if (!isValidInput(book)) {
    // Guard statement, return error/fail
    // TODO
  }

  MySqlConnection dbConnection = await database.createConnection();

  // Insert the book
  // TODO: try catch

  int affectedRows = 0;
  for (int i = 0; i < book['quantity']; i++) {
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
    affectedRows += result.affectedRows;
  }

  dbConnection.close();
  return Response.ok("Book added. Affected rows: $affectedRows");
}

Future<Response> getBookStockList() async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection.query(
        'SELECT title, author, COUNT(isbn) as stock ' +
            'FROM book ' +
            'GROUP BY isbn ' +
            'ORDER BY isbn ' +
            'LIMIT 25');

    List<Map> resultsList = <Map<String, dynamic>>[];
    for (var row in results) {
      resultsList.add(row.fields);
    }

    Map books = Map<String, dynamic>();
    books['books'] = resultsList;

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

Future<Response> returnBook(String uuid) async {
  if (!await isAlreadyBorrowed(uuid)) {
    return Response(HttpStatus.conflict, body: "Book is not borrowed!");
  }

  MySqlConnection dbConnection = await database.createConnection();
  try {
    Results result = await dbConnection.query(
        'UPDATE book ' +
            'SET borrower_id = null, borrowed_on = null ' +
            'WHERE book_id = ?  ',
        [uuid]);

    print('Book Returned. Affected rows: ${result.affectedRows}');

    return Response(HttpStatus.noContent, body: 'Book returned.');
  } on MySqlException catch (e) {
    print(e);
    // Other MySqlException errors
    return Response.internalServerError(body: e.message);
  } catch (e) {
    print(e);
    if (e is TimeoutException || e is SocketException) {
      return Response.internalServerError(
          body: 'Connection failed. Please try again later.');
    }
    // Catch-all other exceptions
    return Response.internalServerError(
        body: 'Something went wrong on our end. Please try again later.');
  } finally {
    dbConnection.close();
  }
}

Future<Response> searchBooks(String searchQuery) async {
  final List keywords = searchQuery.split(' ');
  // Build the query to search for each keyword in title or author
  final String finalQuery = buildSearchQuery(keywords);
  // Double the keywords to use them for both title and author
  final List finalValues = buildSearchValues(keywords);
  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection.query(finalQuery, finalValues);

    List<Map> resultsList = <Map<String, dynamic>>[];
    for (var row in results) {
      resultsList.add(row.fields);
    }

    Map searchResults = Map<String, dynamic>();
    searchResults['results'] = resultsList;

    return Response.ok(jsonEncode(searchResults), headers: {
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

String buildSearchQuery(List<String> keywords) {
  final String queryStart = 'SELECT title, author, ' +
      'COUNT(isbn) as stock, (COUNT(isbn) - COUNT(borrower_id)) as available ' +
      'FROM book WHERE ';
  final String queryEnd = ' GROUP BY isbn ORDER BY author, title';

  String titleQuery = 'title LIKE ?';
  String authorQuery = ' OR author LIKE ?';
  for (var i = 1; i < keywords.length; i++) {
    if (!keywords[i].isEmpty) {
      titleQuery += ' OR title LIKE ?';
      authorQuery += ' OR author LIKE ?';
    }
  }
  return queryStart + titleQuery + authorQuery + queryEnd;
}

List buildSearchValues(List<String> keywords) {
  List<String> finalValues = [];
  finalValues.addAll(keywords);
  finalValues.addAll(keywords);

  // Remove empty strings, add % symbols
  for (int i = 0; i < finalValues.length; i++) {
    if (finalValues[i].isEmpty) {
      finalValues.removeAt(i);
      i--;
    } else {
      finalValues[i] = '%${finalValues[i]}%';
    }
  }
  return finalValues;
}

bool isValidInput(Map<String, dynamic> book) {
  // TODO
  return false;
}
