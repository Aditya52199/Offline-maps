import 'package:latlong2/latlong.dart';

class RouteParser {
  List<LatLng> parseGeoJsonCoordinates(List<dynamic> coordinates) {
    return coordinates
        .map((p) => LatLng(
              (p[1] as num).toDouble(),
              (p[0] as num).toDouble(),
            ))
        .toList();
  }
}
