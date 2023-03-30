import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart';

Future<MySqlConnection> createConnection() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

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
