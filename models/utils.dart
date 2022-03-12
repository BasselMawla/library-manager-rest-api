// models/utils.dart

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart' show env;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

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

String generateJwt(String account_id) {
  //String username, bool isLibrarian) {
  final jwt = JWT(
    {
      'iat': DateTime.now().millisecondsSinceEpoch,
    },
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
  } on JWTError catch (e) {
    print(e.message); // e: invalid signature
  }
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
      }

      final updatedRequest = request.change(context: {
        'jwtAuth': jwt,
      });
      // Continue with updated request
      return await handler(updatedRequest);
    };
  };
}

Middleware authLibrarians() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.context['jwtAuth'] == null) {
        return Response.forbidden('Not allowed: must be a librarian');
      }
      // Continue down the pipeline
      return null;
    },
  );
}
