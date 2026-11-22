import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class RoadNode {
  final String id;
  final String name;
  final double lat;
  final double lon;

  const RoadNode({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  LatLng get toLatLng => LatLng(lat, lon);
}

class RoadEdge {
  final String from;
  final String to;
  final double distanceKm;
  final double durationMins;
  final String shape;
  final List<Map<String, dynamic>> maneuvers;

  const RoadEdge({
    required this.from,
    required this.to,
    required this.distanceKm,
    required this.durationMins,
    required this.shape,
    required this.maneuvers,
  });
}

/// 100% On-Device Offline Road Routing Engine for Central India & Bhopal.
///
/// Executes fast A* pathfinding over real highway & urban road corridors,
/// returning decoded road geometries (Polyline6) and turn maneuvers without
/// requiring Docker, internet, or any external service.
class OfflineRoadRouter {
  static final OfflineRoadRouter _instance = OfflineRoadRouter._internal();
  factory OfflineRoadRouter() => _instance;
  OfflineRoadRouter._internal();

  bool _isLoaded = false;
  final Map<String, RoadNode> _nodes = {};
  final Map<String, List<RoadEdge>> _adjacency = {};

  Future<void> loadRoadNetwork() async {
    if (_isLoaded) return;
    try {
      final jsonString =
          await rootBundle.loadString('assets/routing/road_network.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final rawNodes = data['nodes'] as List<dynamic>;
      for (final n in rawNodes) {
        final node = RoadNode(
          id: n['id'] as String,
          name: n['name'] as String,
          lat: (n['lat'] as num).toDouble(),
          lon: (n['lon'] as num).toDouble(),
        );
        _nodes[node.id] = node;
        _adjacency[node.id] = [];
      }

      final rawEdges = data['edges'] as List<dynamic>;
      for (final e in rawEdges) {
        final from = e['from'] as String;
        final to = e['to'] as String;
        final dist = (e['distanceKm'] as num).toDouble();
        final dur = (e['durationMins'] as num).toDouble();
        final shape = e['shape'] as String? ?? '';
        final rawManeuvers = (e['maneuvers'] as List<dynamic>?) ?? [];

        final maneuvers = rawManeuvers
            .map((m) => {
                  'instruction': m['instruction'] as String? ?? '',
                  'length': (m['length'] as num?)?.toDouble() ?? 0.0,
                })
            .toList();

        final edge = RoadEdge(
          from: from,
          to: to,
          distanceKm: dist,
          durationMins: dur,
          shape: shape,
          maneuvers: maneuvers,
        );

        _adjacency.putIfAbsent(from, () => []).add(edge);
      }

      _isLoaded = true;
      debugPrint(
        'OfflineRoadRouter: Loaded ${_nodes.length} nodes and ${rawEdges.length} road edges.',
      );
    } catch (e) {
      debugPrint('OfflineRoadRouter initialization note: $e');
    }
  }

  /// Calculates a road-following route between [start] and [end]
  /// completely on-device.
  Future<Map<String, dynamic>> calculateRoute(LatLng start, LatLng end) async {
    await loadRoadNetwork();

    if (_nodes.isEmpty) {
      return _straightLineFallback(start, end);
    }

    // 1. Snap start and end to nearest road network nodes
    final startNode = _findNearestNode(start);
    final endNode = _findNearestNode(end);

    if (startNode == null || endNode == null) {
      return _straightLineFallback(start, end);
    }

    // Direct proximity: points snap to the same junction
    if (startNode.id == endNode.id) {
      final dist = const Distance().as(LengthUnit.Kilometer, start, end);
      return {
        'distanceKm': max(dist, 0.1),
        'durationMins': max((dist / 25.0 * 60.0).round(), 1),
        'waypoints': [start, startNode.toLatLng, end],
        'maneuvers': [
          {'instruction': 'Proceed to ${endNode.name}', 'length': dist}
        ],
      };
    }

    // 2. Run A* (A-Star) search across the road network
    final edgePath = _runAStar(startNode.id, endNode.id);

    if (edgePath == null || edgePath.isEmpty) {
      return _straightLineFallback(start, end);
    }

    // 3. Assemble complete road waypoints by decoding Polyline6 shapes
    final List<LatLng> waypoints = [start];
    double totalDistanceKm = 0.0;
    double totalDurationMins = 0.0;
    final List<Map<String, dynamic>> allManeuvers = [];

    // Distance from start location to first road junction
    final startDist =
        const Distance().as(LengthUnit.Kilometer, start, startNode.toLatLng);
    totalDistanceKm += startDist;

    for (final edge in edgePath) {
      totalDistanceKm += edge.distanceKm;
      totalDurationMins += edge.durationMins;
      allManeuvers.addAll(edge.maneuvers);

      if (edge.shape.isNotEmpty) {
        final decoded = _decodePolyline6(edge.shape);
        // Ensure continuous direction
        if (decoded.isNotEmpty) {
          final first = decoded.first;
          final last = decoded.last;
          final srcNode = _nodes[edge.from]!;
          final distToFirst = const Distance()
              .as(LengthUnit.Meter, srcNode.toLatLng, first);
          final distToLast = const Distance()
              .as(LengthUnit.Meter, srcNode.toLatLng, last);

          if (distToFirst > distToLast) {
            waypoints.addAll(decoded.reversed);
          } else {
            waypoints.addAll(decoded);
          }
        }
      } else {
        waypoints.add(_nodes[edge.to]!.toLatLng);
      }
    }

    // Distance from final road junction to destination
    final endDist =
        const Distance().as(LengthUnit.Kilometer, endNode.toLatLng, end);
    totalDistanceKm += endDist;
    waypoints.add(end);

    // Approximate urban transfer speed for start/end connectors
    totalDurationMins += ((startDist + endDist) / 20.0 * 60.0);

    return {
      'distanceKm': double.parse(totalDistanceKm.toStringAsFixed(1)),
      'durationMins': max(totalDurationMins.round(), 1),
      'waypoints': waypoints,
      'maneuvers': allManeuvers,
    };
  }

  /// A* algorithm to find optimal sequence of road edges
  List<RoadEdge>? _runAStar(String startId, String goalId) {
    final goalNode = _nodes[goalId]!;
    final openSet = <String>{startId};
    final cameFrom = <String, RoadEdge>{};

    final gScore = <String, double>{startId: 0.0};
    final fScore = <String, double>{
      startId: _heuristic(_nodes[startId]!, goalNode)
    };

    while (openSet.isNotEmpty) {
      // Find node in openSet with lowest fScore
      String current = openSet.first;
      double lowestF = fScore[current] ?? double.infinity;
      for (final node in openSet) {
        final score = fScore[node] ?? double.infinity;
        if (score < lowestF) {
          lowestF = score;
          current = node;
        }
      }

      if (current == goalId) {
        // Reconstruct path
        final path = <RoadEdge>[];
        String curr = goalId;
        while (cameFrom.containsKey(curr)) {
          final edge = cameFrom[curr]!;
          path.insert(0, edge);
          curr = edge.from;
        }
        return path;
      }

      openSet.remove(current);
      final neighbors = _adjacency[current] ?? [];

      for (final edge in neighbors) {
        final neighbor = edge.to;
        final tentativeG = (gScore[current] ?? double.infinity) + edge.distanceKm;

        if (tentativeG < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = edge;
          gScore[neighbor] = tentativeG;
          fScore[neighbor] =
              tentativeG + _heuristic(_nodes[neighbor]!, goalNode);
          openSet.add(neighbor);
        }
      }
    }

    return null;
  }

  double _heuristic(RoadNode a, RoadNode b) {
    const d = Distance();
    return d.as(LengthUnit.Kilometer, a.toLatLng, b.toLatLng);
  }

  RoadNode? _findNearestNode(LatLng point) {
    RoadNode? nearest;
    double minDistance = double.infinity;
    const distanceCalc = Distance();

    for (final node in _nodes.values) {
      final d = distanceCalc.as(LengthUnit.Kilometer, point, node.toLatLng);
      if (d < minDistance) {
        minDistance = d;
        nearest = node;
      }
    }
    return nearest;
  }

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

  Map<String, dynamic> _straightLineFallback(LatLng start, LatLng end) {
    final distanceKm = const Distance().as(LengthUnit.Kilometer, start, end);
    final waypoints = <LatLng>[];
    const steps = 15;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      waypoints.add(LatLng(lat, lng));
    }
    return {
      'distanceKm': double.parse((distanceKm * 1.25).toStringAsFixed(1)),
      'durationMins': max(((distanceKm * 1.25) / 30.0 * 60.0).round(), 1),
      'waypoints': waypoints,
      'maneuvers': [
        {'instruction': 'Proceed along road to destination', 'length': distanceKm}
      ],
    };
  }
}
