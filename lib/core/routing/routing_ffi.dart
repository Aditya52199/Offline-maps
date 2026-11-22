import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'offline_road_router.dart';

class RoutingFfi {
  bool _isInitialized = false;
  bool _isValhallaServiceAvailable = false;
  final OfflineRoadRouter _offlineRoadRouter = OfflineRoadRouter();

  /// Determine the appropriate endpoint depending on platform:
  /// - Android Emulator: 10.0.2.2 points to host PC localhost
  /// - Windows / Web / Linux: localhost
  /// - Default port: 8002
  String get _valhallaBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8002';
    }
    return 'http://localhost:8002';
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Pre-load on-device offline road graph
    await _offlineRoadRouter.loadRoadNetwork();

    // Fast probe for external Valhalla service container
    try {
      final response = await http
          .get(Uri.parse('$_valhallaBaseUrl/status'))
          .timeout(const Duration(milliseconds: 350));
      if (response.statusCode == 200) {
        _isValhallaServiceAvailable = true;
        debugPrint('Valhalla HTTP service connected at $_valhallaBaseUrl');
      }
    } catch (_) {
      _isValhallaServiceAvailable = false;
      debugPrint('Valhalla HTTP service unreachable; operating 100% on-device offline.');
    }
    _isInitialized = true;
  }

  /// Calculates a real road network route:
  /// - Uses local Valhalla service if available (development/emulator).
  /// - Uses 100% On-Device OfflineRoadRouter if mobile standalone with no server.
  Future<Map<String, dynamic>> calculateRoute(LatLng start, LatLng end) async {
    await initialize();

    // 1. If Valhalla service container is reachable, use full dynamic routing
    if (_isValhallaServiceAvailable) {
      try {
        final requestBody = jsonEncode({
          'locations': [
            {'lat': start.latitude, 'lon': start.longitude, 'type': 'break'},
            {'lat': end.latitude, 'lon': end.longitude, 'type': 'break'},
          ],
          'costing': 'auto',
          'directions_options': {'units': 'kilometers'},
        });

        final response = await http
            .post(
              Uri.parse('$_valhallaBaseUrl/route'),
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            )
            .timeout(const Duration(milliseconds: 900));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data.containsKey('trip')) {
            final trip = data['trip'] as Map<String, dynamic>;
            final summary = trip['summary'] as Map<String, dynamic>;
            final legs = trip['legs'] as List<dynamic>;

            final double distanceKm = (summary['length'] as num).toDouble();
            final int durationMins = ((summary['time'] as num) / 60.0).round();

            final List<LatLng> waypoints = [];
            final List<Map<String, dynamic>> maneuvers = [];

            if (legs.isNotEmpty) {
              final leg = legs[0] as Map<String, dynamic>;
              final shapeStr = leg['shape'] as String?;
              if (shapeStr != null && shapeStr.isNotEmpty) {
                waypoints.addAll(_decodePolyline6(shapeStr));
              }
              for (final m in (leg['maneuvers'] as List<dynamic>? ?? [])) {
                maneuvers.add({
                  'instruction': m['instruction'] as String? ?? '',
                  'length': (m['length'] as num?)?.toDouble() ?? 0.0,
                });
              }
            }

            if (waypoints.isNotEmpty) {
              debugPrint(
                'Route via Valhalla service: $distanceKm km, $durationMins mins, ${waypoints.length} points',
              );
              return {
                'distanceKm': distanceKm,
                'durationMins': durationMins,
                'waypoints': waypoints,
                'maneuvers': maneuvers,
              };
            }
          }
        }
      } catch (e) {
        debugPrint('Valhalla service call timed out, falling back to on-device router: $e');
        _isValhallaServiceAvailable = false;
      }
    }

    // 2. Pure On-Device Offline Routing (100% offline mobile)
    return await _offlineRoadRouter.calculateRoute(start, end);
  }

  /// Decodes Valhalla Polyline6 format (precision = 1e6) into LatLng points.
  static List<LatLng> _decodePolyline6(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e6, lng / 1e6));
    }

    return points;
  }
}
