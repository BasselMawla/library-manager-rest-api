// /models/authModel.dart

import 'package:mysql1/mysql1.dart';
import '../database_connection.dart' as database;
import 'utils.dart';

addUser(Map<String, dynamic> credentials) async {
  if (!isValidInput(credentials)) {
    // Guard statement, return error/fail
    // TODO
  }

  MySqlConnection dbConnection = await database.createConnection();

  // Add the user, if not unique an error is returned which we can catch
  Results result = await dbConnection.query(
      'INSERT INTO account (username, first_name, last_name, password, salt) ' +
          'VALUE (?, ?, ?, ?, now())',
      [
        credentials['username'],
        hashPassword(credentials['password'], generateSalt()),
      ]);
  print('Book inserted. Affected rows: ${result.affectedRows}');

  dbConnection.close();
}

bool isValidInput(Map<String, dynamic> book) {
  // TODO
  return false;
}
