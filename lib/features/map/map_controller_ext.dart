import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

extension MapControllerTracking on MapController {
  void centerOn(LatLng position, {double? zoom}) {
    move(position, zoom ?? camera.zoom);
  }
}
