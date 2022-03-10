// models/utils.dart

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

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
