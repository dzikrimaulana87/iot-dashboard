class IdealConfigModel {
  final double minTemp;
  final double maxTemp;
  final double minHum;
  final double maxHum;

  IdealConfigModel({
    required this.minTemp,
    required this.maxTemp,
    required this.minHum,
    required this.maxHum,
  });

  factory IdealConfigModel.fromJson(Map<String, dynamic> json) {
    return IdealConfigModel(
      minTemp: json['minTemp'] ?? 20.0,
      maxTemp: json['maxTemp'] ?? 30.0,
      minHum: json['minHum'] ?? 40.0,
      maxHum: json['maxHum'] ?? 70.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'minHum': minHum,
      'maxHum': maxHum,
    };
  }
}
