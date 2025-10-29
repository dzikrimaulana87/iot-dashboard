class SensorData {
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final String statusTemperature;
  final String statusHumidity;
  SensorData({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.statusTemperature,
    required this.statusHumidity,
  });
}
