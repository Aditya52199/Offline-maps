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

  /// Generates a list of route waypoints between [start] and [end].
  List<LatLng> generateRouteWaypoints(LatLng start, LatLng end, {int steps = 10}) {
    final List<LatLng> waypoints = [];

    for (int i = 0; i <= steps; i++) {
      final double fraction = i / steps;
      final double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final double lng = start.longitude + (end.longitude - start.longitude) * fraction;
      waypoints.add(LatLng(lat, lng));
    }
    return waypoints;
  }

  /// Calculates straight-line distance in kilometers between [start] and [end].
  double calculateDistanceKm(LatLng start, LatLng end) {
    const Distance distanceCalc = Distance();
    return distanceCalc.as(LengthUnit.Kilometer, start, end);
  }
}
