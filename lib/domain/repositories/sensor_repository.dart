import '../entities/sensor_data.dart';

abstract class SensorRepository {
  Future<void> saveSensorData(double temp, double hum);
  Future<SensorData?> getLatestSensorData();
  Future<List<SensorData>> getAllSensorData();
}
