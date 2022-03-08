import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart' show load, env;

Future<MySqlConnection> createConnection() async {
  // Load environment variables from .env file
  load();

  print(env['databaseName'].runtimeType);

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

void closeConnection(MySqlConnection dbConnection) async {
  await dbConnection.close();
}
