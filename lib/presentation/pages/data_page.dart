import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/repositories/sensor_repository_impl.dart';
import '../../core/utils/excel_exporter.dart';
import 'package:intl/intl.dart';

class DataPage extends StatefulWidget {
  final SensorRepositoryImpl sensorRepo;
  const DataPage({super.key, required this.sensorRepo});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = widget.sensorRepo.getAllSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historical Data')),
      body: FutureBuilder<List>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data'));
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Grafik Suhu & Kelembapan dalam satu chart
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Temperature & Humidity Over Time'),
                  legend: Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat('HH:mm'),
                    intervalType: DateTimeIntervalType.minutes,
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  series: <LineSeries>[
                    LineSeries<SensorDataPoint, DateTime>(
                      dataSource: data
                          .map(
                            (d) => SensorDataPoint(d.timestamp, d.temperature),
                          )
                          .toList(),
                      xValueMapper: (SensorDataPoint d, _) => d.time,
                      yValueMapper: (SensorDataPoint d, _) => d.value,
                      name: 'Temperature (°C)',
                      color: Colors.red,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        width: 6,
                        height: 6,
                      ),
                    ),
                    LineSeries<SensorDataPoint, DateTime>(
                      dataSource: data
                          .map((d) => SensorDataPoint(d.timestamp, d.humidity))
                          .toList(),
                      xValueMapper: (SensorDataPoint d, _) => d.time,
                      yValueMapper: (SensorDataPoint d, _) => d.value,
                      name: 'Humidity (%)',
                      color: Colors.blue,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        width: 6,
                        height: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final file = await ExcelExporter.exportToExcel(data);
                  if (file != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved to ${file.path}')),
                    );
                  }
                },
                icon: const Icon(Icons.file_download),
                label: const Text('Download Excel'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Helper class untuk data chart
class SensorDataPoint {
  final DateTime time;
  final double value;

  SensorDataPoint(this.time, this.value);
}
