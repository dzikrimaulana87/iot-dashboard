import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repositories/sensor_repository_impl.dart';

class HttpServerManager {
  late HttpServer _server;
  int port = 8080;
  String? ipAddress;

  final SensorRepositoryImpl _sensorRepo;

  HttpServerManager(this._sensorRepo);

  Router get _router {
    final router = Router();

    // Endpoint: POST /sensor → terima data suhu & kelembapan
    router.post('/sensor', (Request req) async {
      final body = await req.readAsString();
      final json = jsonDecode(body);
      final temp = (json['temperature'] as num?)?.toDouble() ?? 0.0;
      final humidity = (json['humidity'] as num?)?.toDouble() ?? 0.0;
      final statusHumidity = (json['status_humidity'] as String?) ?? 'unknown';
      final statusTemp = (json['status_temperature'] as String?) ?? 'unknown';

      await _sensorRepo.saveSensorData(
        temp,
        humidity,
        statusTemp,
        statusHumidity,
      );

      return Response.ok('Data received');
    });

    // Endpoint: GET /ideal → kirim konfigurasi ideal
    router.get('/ideal', (Request req) async {
      final prefs = await SharedPreferences.getInstance();
      final minTemp = prefs.getDouble('min_temp') ?? 20.0;
      final maxTemp = prefs.getDouble('max_temp') ?? 30.0;
      final minHum = prefs.getDouble('min_hum') ?? 40.0;
      final maxHum = prefs.getDouble('max_hum') ?? 70.0;

      return Response.ok(
        jsonEncode({
          'temp': {'min': minTemp, 'max': maxTemp},
          'humidity': {'min': minHum, 'max': maxHum},
        }),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }

  Future<void> startServer() async {
    final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
    _server = await io.serve(handler, InternetAddress.anyIPv4, port);

    // Dapatkan IP lokal
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      ipAddress = interfaces.first.addresses.first.address;
    } catch (e) {
      ipAddress = '127.0.0.1';
    }
  }

  void stopServer() {
    _server.close();
  }

  String get serverInfo => 'http://$ipAddress:$port';
}
