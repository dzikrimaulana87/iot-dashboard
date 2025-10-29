import '../repositories/sensor_repository.dart';
import '../entities/sensor_data.dart';

class GetLatestSensorData {
  final SensorRepository repository;

  GetLatestSensorData(this.repository);

  Future<SensorData?> call() async {
    return await repository.getLatestSensorData();
  }
}
