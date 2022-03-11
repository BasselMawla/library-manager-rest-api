// routes/accounts_controller.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert' show jsonDecode, JsonEncoder;
import '../models/accounts_model.dart' as accountsModel;

class AccountsController {
  Router get router {
    final router = Router();

    router.post('/register', (Request request) async {
      final requestBody = await request.readAsString();
      final Map<String, dynamic> credentials = jsonDecode(requestBody);

      final String username = credentials['username'];
      final String password = credentials['password'];

      // Check that credentials exist
      if (username == null ||
          password == null ||
          username.isEmpty ||
          password.isEmpty) {
        return Response(400, body: "Please enter a username and password");
      }

      //authModel.addUser();
    });

    return router;
  }
}
