// routes/home_controller.dart

import "dart:io";

import "package:dotenv/dotenv.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "dart:convert" show jsonEncode;

class HomeController {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  Router get router {
    final router = Router();

    router.get("/", (Request request) async {
      Map collectionLinks = {
        "books": "${env["base_url"]}/books",
        "students": "${env["base_url"]}/students",
        "accounts": "${env["base_url"]}/accounts",
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
