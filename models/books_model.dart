// books_model.dart

import 'package:mysql1/mysql1.dart';
import '../database_connection.dart' as database;

addBook(Map<String, dynamic> book) async {
  if (!isValidInput(book)) {
    // Guard statement, return error/fail
    // TODO
  }

  MySqlConnection dbConnection = await database.createConnection();

  // Insert the book
  Results result = await dbConnection.query(
      'INSERT INTO book (book_id, isbn, title, author, dewey_number, added_on) ' +
          'VALUE (UUID(), ?, ?, ?, ?, now())',
      [
        book['isbn'],
        book['title'],
        book['author'],
        book['dewey_number'],
      ]);
  print('Book inserted. Affected rows: ${result.affectedRows}');

  dbConnection.close();
}

bool isValidInput(Map<String, dynamic> book) {
  // TODO
  return false;
}
