// routes/accounts_controller.dart

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert' show jsonDecode;
import '../models/accounts_model.dart' as accountsModel;
import '../models/utils.dart';

class AccountsController {
  Router get router {
    final router = Router();

    router.post('/', (Request request) async {
      final requestBody = await request.readAsString();
      try {
        final Map<String, dynamic> accountInfo = jsonDecode(requestBody);

        // Check that all info exists
        if (isMissingInput([
          accountInfo['username'],
          accountInfo['first_name'],
          accountInfo['last_name'],
          accountInfo['password'],
        ])) {
          return Response(400, body: "Please enter all user information.");
        }
        return accountsModel.addAccount(accountInfo);
      } on FormatException catch (e) {
        print(e);
        return Response(400, body: "Invalid JSON!");
      }
    });

    router.get('/', (Request request) async {
      final requestBody = await request.readAsString();
      try {
        final Map<String, dynamic> credentials = jsonDecode(requestBody);

        // Check that all info exists
        if (isMissingInput([
          credentials['username'],
          credentials['password'],
        ])) {
          return Response(HttpStatus.badRequest,
              body: "Please enter a username and password.");
        }
        return accountsModel.loginAccount(
            credentials['username'], credentials['password']);
      } on FormatException catch (e) {
        print(e);
        return Response(HttpStatus.badRequest, body: "Invalid JSON!");
      }
    });

    return router;
  }
}
