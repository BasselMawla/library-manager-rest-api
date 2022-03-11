// /models/authModel.dart

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
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
    return Response(201,
        body: 'User inserted. Affected rows: ${result.affectedRows}');
  } on MySqlException catch (e) {
    print(e);
    // Duplicate entry error
    if (e.errorNumber == 1062) {
      return Response(409, body: "Username already exists!");
    }
  } catch (e) {
    print(e);
    return Response.internalServerError(
        body: "Something went wrong on our side. Please try again later.");
  } finally {
    print("Closing connection to DB");
    dbConnection.close();
  }
}

bool isValidCredentials(Map<String, dynamic> userInfo) {
  // TODO
  return true;
}
