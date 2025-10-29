class SensorDataModel {
  final int? id;
  final double temperature;
  final double humidity;
  final String statusTemperature;
  final String statusHumidity;
  final DateTime timestamp;

  SensorDataModel({
    this.id,
    required this.temperature,
    required this.humidity,
    required this.statusTemperature,
    required this.statusHumidity,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'status_temperature': statusTemperature,
      'status_humidity': statusHumidity,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      id: map['id'] as int?,
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      statusTemperature: map['status_temperature'] as String? ?? '',
      statusHumidity: map['status_humidity'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
