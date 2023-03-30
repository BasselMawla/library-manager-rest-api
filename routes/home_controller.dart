// routes/home_controller.dart

import "dart:io";

import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "dart:convert" show jsonEncode;

class HomeController {
  Router get router {
    final router = Router();

    router.get("/", (Request request) async {
      Map collectionLinks = {
        "books": " https://mobile-library-api.herokuapp.com/books",
        "students": "https://mobile-library-api.herokuapp.com/students",
        "accounts": "https://mobile-library-api.herokuapp.com/accounts",
      };
      return Response.ok(
        jsonEncode(collectionLinks),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    return router;
  }
}
