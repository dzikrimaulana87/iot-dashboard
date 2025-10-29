import 'package:shared_preferences/shared_preferences.dart';

class ConfigLocalDataSource {
  Future<void> saveIdealConfig({
    required double minTemp,
    required double maxTemp,
    required double minHum,
    required double maxHum,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('min_temp', minTemp);
    prefs.setDouble('max_temp', maxTemp);
    prefs.setDouble('min_hum', minHum);
    prefs.setDouble('max_hum', maxHum);
  }

  Future<Map<String, double>> getIdealConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'min_temp': prefs.getDouble('min_temp') ?? 20.0,
      'max_temp': prefs.getDouble('max_temp') ?? 30.0,
      'min_hum': prefs.getDouble('min_hum') ?? 40.0,
      'max_hum': prefs.getDouble('max_hum') ?? 70.0,
    };
  }
}
