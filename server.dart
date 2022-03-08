// server.dart

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'database_connection.dart' as database;
import 'route_handler.dart';

void main() async {
  final route_handler = RouteHandler();

  final server = await shelf_io.serve(
    route_handler.handler,
    'localhost',
    5050,
  );

  database.createConnection();

  print('Serving at http://${server.address.host}:${server.port}');
}
