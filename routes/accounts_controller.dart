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
      Map<String, dynamic> credentials = jsonDecode(requestBody);

      // TODO: Check that credentials are valid input

      //authModel.addUser();
    });

    return router;
  }
}
