import '../repositories/config_repository.dart';

class SaveIdealConfig {
  final ConfigRepository repository;

  SaveIdealConfig(this.repository);

  Future<void> call({
    required double minTemp,
    required double maxTemp,
    required double minHum,
    required double maxHum,
  }) async {
    await repository.saveIdealConfig(
      minTemp: minTemp,
      maxTemp: maxTemp,
      minHum: minHum,
      maxHum: maxHum,
    );
  }
}
