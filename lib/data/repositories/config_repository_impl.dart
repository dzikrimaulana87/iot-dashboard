import '../../domain/entities/ideal_config.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/local/config_local_data_source.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigLocalDataSource _dataSource;

  ConfigRepositoryImpl(this._dataSource);

  @override
  Future<void> saveIdealConfig({
    required double minTemp,
    required double maxTemp,
    required double minHum,
    required double maxHum,
  }) async {
    await _dataSource.saveIdealConfig(
      minTemp: minTemp,
      maxTemp: maxTemp,
      minHum: minHum,
      maxHum: maxHum,
    );
  }

  @override
  Future<IdealConfig> getIdealConfig() async {
    final map = await _dataSource.getIdealConfig();
    return IdealConfig(
      minTemp: map['min_temp']!,
      maxTemp: map['max_temp']!,
      minHum: map['min_hum']!,
      maxHum: map['max_hum']!,
    );
  }
}
