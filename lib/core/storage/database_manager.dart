import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database? _db;

  static const List<Map<String, dynamic>> _fallbackPois = [
    {
      'name': 'Monte Carlo Casino',
      'latitude': 43.7390,
      'longitude': 7.4270,
      'category': 'attraction'
    },
    {
      'name': 'Monaco Harbor',
      'latitude': 43.7350,
      'longitude': 7.4200,
      'category': 'harbor'
    },
    {
      'name': 'Prince\'s Palace of Monaco',
      'latitude': 43.7310,
      'longitude': 7.4210,
      'category': 'palace'
    },
    {
      'name': 'Oceanographic Museum',
      'latitude': 43.7300,
      'longitude': 7.4250,
      'category': 'museum'
    },
    {
      'name': 'Jardin Exotique',
      'latitude': 43.7320,
      'longitude': 7.4130,
      'category': 'park'
    },
    {
      'name': 'Bhopal Central Station',
      'latitude': 23.2599,
      'longitude': 77.4126,
      'category': 'station'
    },
    {
      'name': 'DB City Mall',
      'latitude': 23.2335,
      'longitude': 77.4326,
      'category': 'mall'
    },
    {
      'name': 'Van Vihar National Park',
      'latitude': 23.2285,
      'longitude': 77.3685,
      'category': 'park'
    },
    {
      'name': 'City Hospital',
      'latitude': 43.7340,
      'longitude': 7.4220,
      'category': 'hospital'
    },
    {
      'name': 'Fuel Station',
      'latitude': 43.7370,
      'longitude': 7.4240,
      'category': 'gas_station'
    },
  ];

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'offline_gps.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE poi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            category TEXT
          )
        ''');
        await _seedPois(db);
      },
    );
    return _db!;
  }

  static Future<void> _seedPois(Database db) async {
    final samplePois = [
      {
        'name': 'Monte Carlo Casino',
        'latitude': 43.7390,
        'longitude': 7.4270,
        'category': 'attraction'
      },
      {
        'name': 'Monaco Harbor',
        'latitude': 43.7350,
        'longitude': 7.4200,
        'category': 'harbor'
      },
      {
        'name': 'Prince\'s Palace of Monaco',
        'latitude': 43.7310,
        'longitude': 7.4210,
        'category': 'palace'
      },
      {
        'name': 'Oceanographic Museum',
        'latitude': 43.7300,
        'longitude': 7.4250,
        'category': 'museum'
      },
      {
        'name': 'Jardin Exotique',
        'latitude': 43.7320,
        'longitude': 7.4130,
        'category': 'park'
      },
      {
        'name': 'Bhopal Central Station',
        'latitude': 23.2599,
        'longitude': 77.4126,
        'category': 'station'
      },
      {
        'name': 'DB City Mall',
        'latitude': 23.2335,
        'longitude': 77.4326,
        'category': 'mall'
      },
      {
        'name': 'Van Vihar National Park',
        'latitude': 23.2285,
        'longitude': 77.3685,
        'category': 'park'
      },
      {
        'name': 'City Hospital',
        'latitude': 43.7340,
        'longitude': 7.4220,
        'category': 'hospital'
      },
      {
        'name': 'Fuel Station',
        'latitude': 43.7370,
        'longitude': 7.4240,
        'category': 'gas_station'
      },
    ];
    for (final poi in samplePois) {
      await db.insert('poi', poi);
    }
  }

  Future<List<Map<String, dynamic>>> searchPois(String query) async {
    if (kIsWeb) {
      final q = query.toLowerCase();
      return _fallbackPois.where((p) {
        final name = (p['name'] as String? ?? '').toLowerCase();
        final cat = (p['category'] as String? ?? '').toLowerCase();
        return name.contains(q) || cat.contains(q);
      }).toList();
    }
    final db = await database;
    return await db.query(
      'poi',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> getAllPois() async {
    if (kIsWeb) {
      return List<Map<String, dynamic>>.from(_fallbackPois);
    }
    final db = await database;
    return await db.query('poi');
  }
}
