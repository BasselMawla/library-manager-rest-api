// models/utils.dart

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart' show env;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import '../database_connection.dart' as database;
import 'package:intl/intl.dart' show DateFormat;

String generateSalt() {
  final random = Random.secure();
  final saltBytes = List<int>.generate(32, (index) => random.nextInt(256));
  final String saltString = base64.encode(saltBytes);

  return saltString;
}

String hashPassword(String password, String salt) {
  final codec = Utf8Codec();
  final hashedPassword = codec.encode(password);
  final hmac = Hmac(sha256, hashedPassword);

  final saltBytes = codec.encode(salt);
  final saltedHash = hmac.convert(saltBytes);

  return saltedHash.toString();
}

bool isMissingInput(List<String> keys) {
  for (final key in keys) {
    if (key == null || key.isEmpty) {
      return true;
    }
  }
  return false;
}

String getIdFromJwt(Request request) {
  final jwtAuth = request.context['jwtAuth'] as JWT;
  return jwtAuth.subject;
}

Future<bool> isLibrarian(Request request) async {
  final accountId = getIdFromJwt(request);
  if (accountId == null || accountId.isEmpty) {
    return false;
  }

  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection.query(
        'SELECT is_librarian FROM account WHERE account_id = ?', [accountId]);

    Iterator iterator = results.iterator;
    // If account not found
    if (!iterator.moveNext()) {
      return false;
    }
    // If is_librarian is true
    if (iterator.current['is_librarian'] == 1) {
      return true;
    }
    return false;
  } catch (e) {
    print(e);
    return false;
  } finally {
    dbConnection.close();
  }
}

Future<String> getUsernameFromId(String account_id) async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection.query(
        'SELECT username FROM account WHERE account_id = ?', [account_id]);

    Iterator iterator = results.iterator;
    // If account not found
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current['username'];
  } catch (e) {
    print(e);
    return null;
  } finally {
    dbConnection.close();
  }
}

Future<int> getIdFromUsername(String username) async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection
        .query('SELECT account_id FROM account WHERE username = ?', [username]);

    Iterator iterator = results.iterator;
    // If account not found
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current['account_id'];
  } catch (e) {
    print(e);
    return null;
  } finally {
    dbConnection.close();
  }
}

Future<bool> isAlreadyBorrowed(String uuid) async {
  MySqlConnection dbConnection = await database.createConnection();

  try {
    Results results = await dbConnection
        .query('SELECT borrower_id FROM book WHERE book_id = ?', [uuid]);

    Iterator iterator = results.iterator;
    // If book not found
    if (!iterator.moveNext()) {
      return false;
    }
    if (iterator.current['borrower_id'] != null) {
      return true;
    }
    return false;
  } catch (e) {
    print(e);
    return false;
  } finally {
    dbConnection.close();
  }
}

String getDueDate(DateTime borrowedOn, int loan_days) {
  final dueDate = borrowedOn.add(Duration(days: loan_days));
  final formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
  return formattedDate.toString();
}

String generateJwt(String account_id) {
  //String username, bool isLibrarian) {
  final jwt = JWT(
    {},
    subject: account_id,
    issuer: env['issuer'],
  );
  return jwt.sign(SecretKey(env['secret']));
}

verifyJwt(String token) {
  try {
    final jwt = JWT.verify(token, SecretKey(env['secret']));
    return jwt;
  } on JWTExpiredError {
    print('jwt expired');
    return null;
  } on JWTError catch (e) {
    print(e.message); // e: invalid signature
    return null;
  }
}

Middleware handleCors() {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST',
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, Authorization, username, password',
  };

  return createMiddleware(requestHandler: (Request request) {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: corsHeaders);
    }
    // Continue request
    return null;
  }, responseHandler: (Response response) {
    return response.change(headers: corsHeaders);
  });
}

Middleware handleAuth() {
  return (Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      var jwt;

      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        String token =
            authHeader.substring(7); // Token is whatever is after 'Bearer '
        jwt = verifyJwt(token);
        if (jwt == null) {
          return Response.forbidden("Please log in.");
        }
      }

      final updatedRequest = request.change(context: {
        'jwtAuth': jwt,
      });
      // Continue with updated request
      return await handler(updatedRequest);
    };
  };
}

Middleware checkAuth() {
  return createMiddleware(
    requestHandler: (Request request) {
      bool isBooksRequest =
          (request.handlerPath == '/books' || request.handlerPath == '/books/');

      // If only getting books, no need to auth
      if (isBooksRequest && request.method == 'GET') {
        return null;
      }
      final jwtAuth = request.context['jwtAuth'] as JWT;
      if (jwtAuth == null ||
          jwtAuth.subject == null ||
          jwtAuth.subject.isEmpty) {
        return Response.forbidden(
            jsonEncode({'error': 'Not allowed! Please log in.'}));
      }
      // Continue down the pipeline
      return null;
    },
  );
}
