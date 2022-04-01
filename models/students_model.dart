// models/students_model.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import '../database_connection.dart' as database;
import 'utils.dart';

Future<Response> getAllStudents() async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    // Retrieve students and their borrowing records
    Results results = await dbConnection.query(
        'SELECT username, first_name, last_name, COUNT(borrower_id) as "borrowing_count" ' +
            'FROM account ' +
            'LEFT JOIN book ' +
            'ON account_id = borrower_id ' +
            'WHERE is_librarian = 0 ' +
            'GROUP BY account_id ' +
            'LIMIT 25');

    List<Map> resultsList = <Map<String, dynamic>>[];
    for (var row in results) {
      resultsList.add(row.fields);
    }

    Map students = Map<String, dynamic>();
    students['students'] = resultsList;

    return Response.ok(jsonEncode(students), headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    });
  } catch (e) {
    print(e);
    return Response.internalServerError(
        body: jsonEncode({
      'error': 'Something went wrong on our end. Please try again later.'
    }));
  } finally {
    dbConnection.close();
  }
}

Future<Response> getStudent(String username) async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection.query(
        'SELECT book_id, title as title, borrowed_on, loan_days ' +
            'FROM account, book ' +
            'WHERE username = ? AND account_id = borrower_id ' +
            'LIMIT 25',
        [username]);

    List<Map> resultsList = <Map<String, dynamic>>[];
    for (var row in results) {
      row.fields['due_date'] =
          getDueDate(row.fields['borrowed_on'], row.fields['loan_days']);
      row.fields.remove('borrowed_on');
      resultsList.add(row.fields);
    }

    Map borrowingRecord = Map<String, dynamic>();
    borrowingRecord['borrowed_books'] = resultsList;

    return Response.ok(jsonEncode(borrowingRecord), headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    });
  } catch (e) {
    print(e);
    return Response.internalServerError(
        body: jsonEncode({
      'error': 'Something went wrong on our end. Please try again later.'
    }));
  } finally {
    dbConnection.close();
  }
}

Future<Response> borrowBook(int account_id, String uuid) async {
  MySqlConnection dbConnection = await database.createConnection();
  //Check that book exists
  if (!await bookExists(uuid)) {
    return Response(HttpStatus.conflict,
        body: jsonEncode({'error': 'Book does not exist!'}));
  }
  // Check if book is already borrowed
  if (await isAlreadyBorrowed(uuid)) {
    return Response(HttpStatus.conflict,
        body: jsonEncode({'error': 'Not available! Book already borrowed.'}));
  }
  try {
    Results result = await dbConnection.query(
        'UPDATE book ' +
            'SET borrower_id = ?, borrowed_on = now() ' +
            'WHERE book_id = ?  ',
        [account_id, uuid]);

    return Response(HttpStatus.noContent);
  } on MySqlException catch (e) {
    print(e);
    // Other MySqlException errors
    return Response.internalServerError(body: e.message);
  } catch (e) {
    print(e);
    if (e is TimeoutException || e is SocketException) {
      return Response.internalServerError(
          body: jsonEncode(
              {'error': 'Connection failed. Please try again later.'}));
    }
    // Catch-all other exceptions
    return Response.internalServerError(
        body: jsonEncode({
      'error': 'Something went wrong on our end. Please try again later.'
    }));
  } finally {
    dbConnection.close();
  }
}
