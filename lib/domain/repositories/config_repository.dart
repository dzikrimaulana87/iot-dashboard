import '../entities/ideal_config.dart';

abstract class ConfigRepository {
  Future<void> saveIdealConfig({
    required double minTemp,
    required double maxTemp,
    required double minHum,
    required double maxHum,
  });

  Future<IdealConfig> getIdealConfig();
}
