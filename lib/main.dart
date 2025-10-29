import 'package:flutter/material.dart';
import 'data/datasources/local/sensor_local_data_source.dart';
import 'data/repositories/sensor_repository_impl.dart';
import 'data/datasources/server/http_server_manager.dart';
import 'presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sensorDataSource = SensorLocalDataSource();
  final sensorRepo = SensorRepositoryImpl(sensorDataSource);
  final server = HttpServerManager(sensorRepo);
  await server.startServer();

  runApp(MyApp(server: server, sensorRepo: sensorRepo));
}

class MyApp extends StatelessWidget {
  final HttpServerManager server;
  final SensorRepositoryImpl sensorRepo;

  const MyApp({super.key, required this.server, required this.sensorRepo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardPage(server: server, sensorRepo: sensorRepo),
    );
  }
}
