// server.dart

import 'package:dotenv/dotenv.dart' show env;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'models/utils.dart';
import 'route_handler.dart';

void main() async {
  // load(); // Not needed for Heroku

  final route_handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth())
      .addHandler(RouteHandler().handler);

  final port = int.parse(env['PORT'] ?? '8080');

  final server = await shelf_io.serve(
    route_handler,
    '0.0.0.0',
    port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}
