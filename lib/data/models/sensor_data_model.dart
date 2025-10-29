class SensorDataModel {
  final int? id;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorDataModel({
    this.id,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      id: map['id'],
      temperature: map['temperature'],
      humidity: map['humidity'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
