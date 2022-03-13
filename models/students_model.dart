// models/students_model.dart

import 'dart:convert';
import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import '../database_connection.dart' as database;

Future<Response> getAllStudents() async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    // TODO: Retrieve their borrowing records as well
    Results results = await dbConnection.query(
        'SELECT first_name as "First Name", last_name as "Last Name" ' +
            'FROM account ' +
            'WHERE is_librarian = 0 ' +
            'LIMIT 25');

    List<Map> resultsList = <Map<String, dynamic>>[];
    for (var row in results) {
      resultsList.add(row.fields);
    }

    Map students = Map<String, dynamic>();
    students['results'] = resultsList;

    return Response.ok(jsonEncode(students), headers: {
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    });
  } catch (e) {
    // TODO: Handle more errors
    print(e);
    return Response.internalServerError(
        body: 'Something went wrong on our end. Please try again later.');
  } finally {
    dbConnection.close();
  }
}
