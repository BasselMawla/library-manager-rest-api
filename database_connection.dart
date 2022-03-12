import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart' show env;

Future<MySqlConnection> createConnection() async {
  final MySqlConnection dbConnection =
      await MySqlConnection.connect(ConnectionSettings(
    host: env['databaseHost'],
    port: int.parse(env['databasePort']),
    db: env['databaseName'],
    user: env['databaseUsername'],
    password: env['databasePassword'],
  ));

  return dbConnection;
}
