import '../../domain/entities/sensor_data.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../datasources/local/sensor_local_data_source.dart';
import '../models/sensor_data_model.dart';

class SensorRepositoryImpl implements SensorRepository {
  final SensorLocalDataSource _localDataSource;

  SensorRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveSensorData(double temp, double hum) async {
    await _localDataSource.insert(
      SensorDataModel(
        temperature: temp,
        humidity: hum,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<SensorData?> getLatestSensorData() async {
    final model = await _localDataSource.getLatest();
    if (model == null) return null;
    return SensorData(
      temperature: model.temperature,
      humidity: model.humidity,
      timestamp: model.timestamp,
    );
  }

  @override
  Future<List<SensorData>> getAllSensorData() async {
    final models = await _localDataSource.getAll();
    return models
        .map(
          (m) => SensorData(
            temperature: m.temperature,
            humidity: m.humidity,
            timestamp: m.timestamp,
          ),
        )
        .toList();
  }
}
