import 'package:flutter/material.dart';
import '../../data/repositories/sensor_repository_impl.dart';

class DashboardContentPage extends StatefulWidget {
  final SensorRepositoryImpl sensorRepo;
  const DashboardContentPage({super.key, required this.sensorRepo});

  @override
  State<DashboardContentPage> createState() => _DashboardContentPageState();
}

class _DashboardContentPageState extends State<DashboardContentPage> {
  double? _temp, _hum;
  String _status = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadLatestData();
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
    return RefreshIndicator(
      onRefresh: _loadLatestData,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (_temp != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '🌡️ Temperature: ${_temp!.toStringAsFixed(1)} °C',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        '💧 Humidity: ${_hum!.toStringAsFixed(1)} %',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text('No sensor data received yet.'),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
