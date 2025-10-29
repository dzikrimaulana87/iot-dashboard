import '../repositories/config_repository.dart';
import '../entities/ideal_config.dart';

class GetIdealConfig {
  final ConfigRepository repository;

  GetIdealConfig(this.repository);

  Future<IdealConfig> call() async {
    return await repository.getIdealConfig();
  }
}
