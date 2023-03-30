// /models/authModel.dart

import "dart:convert";
import "dart:io";

import "package:mysql1/mysql1.dart";
import "package:shelf/shelf.dart";
import "dart:async";
import "../database_connection.dart" as database;
import "utils.dart";

Future<Response> addAccount(Map<String, dynamic> accountInfo) async {
  MySqlConnection dbConnection = await database.createConnection();

  final String salt = generateSalt();
  final String hashedPassword = hashPassword(accountInfo["password"], salt);

  // Add the account, if not unique an error is returned which we can catch
  try {
    await dbConnection.query(
        "INSERT INTO account (username, first_name, last_name, password, salt) " +
            "VALUE (?, ?, ?, ?, ?)",
        [
          accountInfo["username"],
          accountInfo["first_name"],
          accountInfo["last_name"],
          hashedPassword,
          salt,
        ]);

    return Response(HttpStatus.created);
  } on MySqlException catch (e) {
    print(e);
    // Duplicate entry error
    if (e.errorNumber == 1062) {
      return Response(
        HttpStatus.conflict,
        body: jsonEncode({"error": "Username already exists!"}),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    }
    // Other MySqlException errors
    return Response.internalServerError(
      body: jsonEncode({"error": e.message}),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      },
    );
  } catch (e) {
    print(e);
    if (e is TimeoutException || e is SocketException) {
      return Response.internalServerError(
        body:
            jsonEncode({"error": "Connection failed. Please try again later."}),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    }
    // Catch-all other exceptions
    return Response.internalServerError(
      body: jsonEncode({
        "error": "Something went wrong on our end. Please try again later."
      }),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      },
    );
  } finally {
    dbConnection.close();
  }
}

Future<Response> loginAccount(String username, String password) async {
  MySqlConnection dbConnection = await database.createConnection();

  // Get the account if it exists
  try {
    Results results = await dbConnection.query(
        "SELECT account_id, password, salt, is_librarian FROM account WHERE username = ?",
        [username]);

    Iterator iterator = results.iterator;
    if (!iterator.moveNext()) {
      return Response.notFound(
        jsonEncode({"error": "Username does not exist."}),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    }
    // Username found. Compare password.
    final account = iterator.current;
    final hashedPassword = hashPassword(password, account["salt"]);

    if (hashedPassword != account["password"]) {
      return Response.forbidden(
        jsonEncode({"error": "Wrong username or password."}),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    }

    // Generate JWT to return with response
    final jwt = generateJwt(account["account_id"].toString());

    return Response.ok(
        json.encode({"jwt": jwt, "is_librarian": account["is_librarian"]}),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        });
  } catch (e) {
    print(e);
    if (e is TimeoutException || e is SocketException) {
      return Response.internalServerError(
        body:
            jsonEncode({"error": "Connection failed. Please try again later."}),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    }
    // Catch-all other exceptions
    return Response.internalServerError(
      body: jsonEncode({
        "error": "Something went wrong on our end. Please try again later."
      }),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      },
    );
  } finally {
    dbConnection.close();
  }
}
