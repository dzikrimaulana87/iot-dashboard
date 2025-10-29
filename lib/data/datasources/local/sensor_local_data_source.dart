import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/sensor_data_model.dart';

class SensorLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sensor.db');
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sensor_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        temperature REAL NOT NULL,
        humidity REAL NOT NULL,
        status_temperature TEXT NOT NULL,
        status_humidity TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insert(SensorDataModel data) async {
    final db = await database;
    await db.insert('sensor_data', data.toMap());
  }

  Future<List<SensorDataModel>> getAll() async {
    final db = await database;
    final maps = await db.query('sensor_data', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => SensorDataModel.fromMap(maps[i]));
  }

  Future<SensorDataModel?> getLatest() async {
    final db = await database;
    final list = await db.query(
      'sensor_data',
      limit: 1,
      orderBy: 'timestamp DESC',
    );
    if (list.isEmpty) return null;
    return SensorDataModel.fromMap(list[0]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('sensor_data');
  }
}
