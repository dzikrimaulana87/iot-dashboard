import '../repositories/sensor_repository.dart';

class SaveSensorData {
  final SensorRepository repository;

  SaveSensorData(this.repository);

  Future<void> call(
    double temperature,
    double humidity,
    String statusTemp,
    String statusHumidity,
  ) async {
    await repository.saveSensorData(
      temperature,
      humidity,
      statusTemp,
      statusHumidity,
    );
  }
}
