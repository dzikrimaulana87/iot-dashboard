import '../../domain/entities/sensor_data.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../datasources/local/sensor_local_data_source.dart';
import '../models/sensor_data_model.dart';

class SensorRepositoryImpl implements SensorRepository {
  final SensorLocalDataSource _localDataSource;

  SensorRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveSensorData(
    double temperature,
    double humidity,
    String statusTemperature,
    String statusHumidity,
  ) async {
    final sensorData = SensorDataModel(
      temperature: temperature,
      humidity: humidity,
      statusTemperature: statusTemperature,
      statusHumidity: statusHumidity,
      timestamp: DateTime.now(),
      // Jika statusTemp/statusHum relevan, tambahkan field-nya di model
    );

    await _localDataSource.insert(sensorData);
  }

  @override
  Future<SensorData?> getLatestSensorData() async {
    final model = await _localDataSource.getLatest();
    if (model == null) return null;

    return SensorData(
      temperature: model.temperature,
      humidity: model.humidity,
      timestamp: model.timestamp,
      statusHumidity: model.statusHumidity,
      statusTemperature: model.statusTemperature,
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
            statusHumidity: m.statusHumidity,
            statusTemperature: m.statusTemperature,
          ),
        )
        .toList();
  }

  /// Mengembalikan stream data sensor untuk digunakan pada StreamBuilder
  @override
  Stream<List<SensorData>> watchAllSensorData() async* {
    // Jika data source tidak menyediakan stream, hanya emit data sekali
    yield await getAllSensorData();
  }

  /// Menghapus semua data sensor dari penyimpanan lokal
  @override
  Future<void> deleteAllSensorData() async {
    await _localDataSource.deleteAll();
  }
}
