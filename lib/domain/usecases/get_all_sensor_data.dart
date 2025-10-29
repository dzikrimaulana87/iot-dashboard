import '../repositories/sensor_repository.dart';
import '../entities/sensor_data.dart';

class GetAllSensorData {
  final SensorRepository repository;

  GetAllSensorData(this.repository);

  Future<List<SensorData>> call() async {
    return await repository.getAllSensorData();
  }
}
