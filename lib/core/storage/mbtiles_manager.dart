// lib/core/storage/mbtiles_manager.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Database; // keep only for potential future use
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart';
import 'package:sqlite3/sqlite3.dart';

/// Manages access to an MBTiles file:
///  * `MbTiles` + `MbTilesVectorTileProvider` for map rendering (Flutter side)
///  * `sqlite3.Database` for raw SQL queries (used by our road‑graph builder)
class MbtilesManager {
  // Underlying MBTiles wrapper (vector tiles)
  MbTiles? _mbtiles;
  MbTilesVectorTileProvider? _tileProvider;

  // Direct SQLite connection for custom queries
  Database? _db;

  /// Default asset path for the offline MBTiles file.
  static const String defaultAssetPath = 'assets/maps/region_map.mbtiles';

  /// Initialise the manager – opens both the vector‑tile provider **and**
  /// a read‑only SQLite handle to the same file.
  Future<void> initialize({String mbtilesPath = defaultAssetPath}) async {
    if (kIsWeb) return; // No file I/O on the web.

    // Clean any previous resources.
    _mbtiles?.close();
    _db?.close();

    final resolvedPath = await _resolveMbtilesFilePath(mbtilesPath);

    // Open the MBTiles wrapper (used by the map widget).
    _mbtiles = MbTiles(path: resolvedPath, editable: false);
    _tileProvider = MbTilesVectorTileProvider(mbtiles: _mbtiles!);

    // Open the *same* file via sqlite3 for raw queries.
    _db = sqlite3.open(resolvedPath, mode: OpenMode.readOnly);
  }

  /// Returns true if the manager has been successfully initialised.
  bool get isInitialized => _tileProvider != null;

  /// Vector‑tile provider required by the Flutter map widget.
  MbTilesVectorTileProvider get provider {
    final p = _tileProvider;
    if (p == null) {
      throw StateError(
          'MbtilesManager not initialized. Call initialize() first.');
    }
    return p;
  }

  /// Direct SQLite database for advanced queries (e.g., raw tile fetches).
  Database get database {
    final d = _db;
    if (d == null) {
      throw StateError(
          'MbtilesManager not initialized. Call initialize() first.');
    }
    return d;
  }

  /// Returns the raw tile bytes for a given Z/X/Y coordinate.
  /// Returns `null` if the tile does not exist.
  Future<Uint8List?> getTile({
    required int zoomLevel,
    required int tileColumn,
    required int tileRow,
  }) async {
    // Ensure we have a DB – the getter throws if not initialised.
    final db = database;

    // Run a simple SELECT against the `tiles` table.
    // sqlite3's API returns a ResultSet; we convert it manually.
    final stmt = db.prepare(
        'SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?');
    final ResultSet result = stmt.select([zoomLevel, tileColumn, tileRow]);
    stmt.close();

    if (result.isEmpty) return null;

    final dynamic data = result.first['tile_data'];
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    return null;
  }

  /// Release all resources (called when the app shuts down or on dispose).
  void dispose() {
    _mbtiles?.close();
    _mbtiles = null;
    _tileProvider = null;
    _db?.close();
    _db = null;
  }

  static const MethodChannel _assetChannel =
      MethodChannel('com.example.my_offline_gps/asset_extractor');

  // -----------------------------------------------------------------
  // Helper: resolves the asset path to a real file on disk.
  // -----------------------------------------------------------------
  static Future<String> _resolveMbtilesFilePath(String path) async {
    final file = File(path);
    if (await file.exists()) return file.path;

    String directoryPath;
    try {
      directoryPath = await getDatabasesPath();
    } catch (_) {
      directoryPath = Directory.systemTemp.path;
    }

    final targetPath = join(directoryPath, basename(path));
    final targetFile = File(targetPath);

    // If already extracted, return immediately with zero memory overhead
    if (await targetFile.exists() && await targetFile.length() > 0) {
      return targetFile.path;
    }

    // On Android, use native chunked streaming (64KB chunks) to prevent OutOfMemoryError on 450MB file
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final String? extractedPath =
            await _assetChannel.invokeMethod<String>('extractAsset', {
          'assetPath': path,
          'targetPath': targetPath,
        });
        if (extractedPath != null && await File(extractedPath).exists()) {
          return extractedPath;
        }
      } catch (e) {
        debugPrint('Native asset streaming note: $e');
      }
    }

    // Fallback for desktop / development environments
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsBytes(bytes, flush: true);
    return targetFile.path;
  }
}