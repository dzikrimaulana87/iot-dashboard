import 'package:flutter/material.dart';
import '../../data/repositories/sensor_repository_impl.dart';
import '../../data/datasources/server/http_server_manager.dart';
import '../pages/data_page.dart';
import '../pages/server_info_page.dart';

class DashboardPage extends StatefulWidget {
  final HttpServerManager server;
  final SensorRepositoryImpl sensorRepo;

  const DashboardPage({
    super.key,
    required this.server,
    required this.sensorRepo,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double? _temp, _hum;
  String _status = 'Loading...';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadLatestData() async {
    final data = await widget.sensorRepo.getLatestSensorData();
    if (mounted) {
      setState(() {
        if (data != null) {
          _temp = data.temperature;
          _hum = data.humidity;
          _status = 'Updated at ${data.timestamp}';
        } else {
          _status = 'No data yet';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT Dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadLatestData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Server: ${widget.server.serverInfo}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text('Status: $_status'),
              const SizedBox(height: 20),
              if (_temp != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Temperature: ${_temp!.toStringAsFixed(1)} °C',
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Humidity: ${_hum!.toStringAsFixed(1)} %',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text('No sensor data received yet.'),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServerInfoPage(server: widget.server),
                      ),
                    ),
                    child: const Text('Server Info'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DataPage(sensorRepo: widget.sensorRepo),
                      ),
                    ),
                    child: const Text('Historical Data'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
