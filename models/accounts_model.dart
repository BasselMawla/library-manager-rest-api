// /models/authModel.dart

import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'dart:async';
import '../database_connection.dart' as database;
import 'utils.dart';

Future<Response> addUser(Map<String, dynamic> userInfo) async {
  if (!isValidCredentials(userInfo)) {
    // Guard statement, return error/fail
    // TODO
  }

  MySqlConnection dbConnection = await database.createConnection();

  final String salt = generateSalt();
  final String hashedPassword = hashPassword(userInfo['password'], salt);

  // Add the user, if not unique an error is returned which we can catch
  try {
    Results result = await dbConnection.query(
        'INSERT INTO account (username, first_name, last_name, password, salt) ' +
            'VALUE (?, ?, ?, ?, ?)',
        [
          userInfo['username'],
          userInfo['first_name'],
          userInfo['last_name'],
          hashedPassword,
          salt,
        ]);

    print('User inserted. Affected rows: ${result.affectedRows}');
    return Response(201, body: 'User registered.');
  } on MySqlException catch (e) {
    print(e);
    // Duplicate entry error
    if (e.errorNumber == 1062) {
      return Response(409, body: "Username already exists!");
    }
    return Response.internalServerError(body: e.message);
  } catch (e) {
    print(e);
    if (e is TimeoutException || e is SocketException) {
      return Response.internalServerError(
          body: 'Connection failed. Please try again later.');
    }
    return Response.internalServerError(
        body: 'Something went wrong on our side. Please try again later.');
  } finally {
    print("Closing connection to DB");
    dbConnection.close();
  }
}

bool isValidCredentials(Map<String, dynamic> userInfo) {
  // TODO
  return true;
}
