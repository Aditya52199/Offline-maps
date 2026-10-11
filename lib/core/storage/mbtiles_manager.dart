
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';

class MbtilesManager {
  MbTilesTileProvider? _tileProvider;

  Future<void> initialize({
    required String mbtilesPath,
  }) async {
    _tileProvider?.dispose();

    _tileProvider = MbTilesTileProvider.fromPath(
      path: mbtilesPath,
    );
  }

  MbTilesTileProvider get provider {
    final tileProvider = _tileProvider;

    if (tileProvider == null) {
      throw StateError(
        'Call initialize() before accessing the tile provider.',
      );
    }

    return tileProvider;
  }

  void dispose() {
    _tileProvider?.dispose();
    _tileProvider = null;
  }
}
