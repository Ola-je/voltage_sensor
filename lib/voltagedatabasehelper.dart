import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class VoltageDatabaseHelper {
  static final VoltageDatabaseHelper _instance = VoltageDatabaseHelper._internal();
  factory VoltageDatabaseHelper() => _instance;

  VoltageDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'voltage_readings.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            voltage REAL,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertReading(double voltage) async {
    final db = await database;
    await db.insert(
      'readings',
      {
        'voltage': voltage,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllReadings() async {
    final db = await database;
    return await db.query('readings', orderBy: 'timestamp DESC');
  }

  Future<void> deleteAllReadings() async {
    final db = await database;
    try {
      final deletedCount = await db.delete('readings');
      print('Deleted $deletedCount readings successfully');
    } catch (e) {
      print('Error deleting readings: $e');
      throw Exception('Failed to delete readings');
    }
  }
}
