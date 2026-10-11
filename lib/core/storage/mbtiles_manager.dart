import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart';

class MbtilesManager {
  MbTiles? _mbtiles;
  MbTilesVectorTileProvider? _tileProvider;

  /// Default asset path for offline MBTiles.
  static const String defaultAssetPath = 'assets/maps/region_map.mbtiles';

  /// Initialize the offline MBTiles provider.
  Future<void> initialize({
    String mbtilesPath = defaultAssetPath,
  }) async {
    _mbtiles?.dispose();

    final resolvedPath = await _resolveMbtilesFilePath(mbtilesPath);
    _mbtiles = MbTiles(mbtilesPath: resolvedPath);
    _tileProvider = MbTilesVectorTileProvider(mbtiles: _mbtiles!);
  }

  /// Returns true if the manager has been initialized.
  bool get isInitialized => _tileProvider != null;

  /// Returns the initialized vector tile provider.
  MbTilesVectorTileProvider get provider {
    final tileProvider = _tileProvider;
    if (tileProvider == null) {
      throw StateError('MbtilesManager is not initialized. Call initialize() first.');
    }
    return tileProvider;
  }

  /// Release resources when no longer needed.
  void dispose() {
    _mbtiles?.dispose();
    _mbtiles = null;
    _tileProvider = null;
  }

  /// Resolves the filesystem path for the given [path].
  static Future<String> _resolveMbtilesFilePath(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return file.path;
    }

    String directoryPath;
    try {
      directoryPath = await getDatabasesPath();
    } catch (_) {
      directoryPath = Directory.systemTemp.path;
    }

    final targetPath = join(directoryPath, basename(path));
    final targetFile = File(targetPath);

    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    if (!await targetFile.exists() || (await targetFile.length()) != bytes.length) {
      await targetFile.parent.create(recursive: true);
      await targetFile.writeAsBytes(bytes, flush: true);
    }

    return targetFile.path;
  }
}
