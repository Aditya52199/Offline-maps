import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import '../../core/location/gps_manager.dart';
import '../../core/routing/route_parser.dart';
import '../../core/storage/database_manager.dart';
import '../../core/storage/mbtiles_manager.dart';
import '../navigation/navigation_panel.dart';
import '../search/search_overlay.dart';
import 'map_controller_ext.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final MbtilesManager _mbtilesManager = MbtilesManager();
  final DatabaseManager _dbManager = DatabaseManager();
  final GpsManager _gpsManager = GpsManager();
  final RouteParser _routeParser = RouteParser();

  bool _mbtilesReady = false;
  String? _initError;

  // Default initial position centered on Monaco region (matching offline MBTiles asset)
  LatLng _currentPosition = const LatLng(43.7350, 7.4200);
  LatLng? _destinationPosition;
  String? _destinationName;

  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _pois = [];

  String _routeDistance = '';
  String _routeDuration = '';

  @override
  void initState() {
    super.initState();
    _initOfflineMap();
    _loadPois();
    _requestGps();
  }

  Future<void> _initOfflineMap() async {
    try {
      debugPrint('Initializing MBTiles...');
      await _mbtilesManager.initialize();
      debugPrint('MBTiles initialized successfully!');
      if (mounted) {
        setState(() {
          _mbtilesReady = true;
          _initError = null;
        });
      }
    } catch (e, stack) {
      debugPrint('Error initializing MBTiles: $e\n$stack');
      if (mounted) {
        setState(() {
          _mbtilesReady = false;
          _initError = e.toString();
        });
      }
    }
  }

  Future<void> _loadPois() async {
    final pois = await _dbManager.getAllPois();
    if (mounted) {
      setState(() {
        _pois = pois;
      });
    }
  }

  Future<void> _requestGps() async {
    final hasPermission = await _gpsManager.requestPermission();
    if (hasPermission) {
      _gpsManager.positionStream.listen((pos) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
          });
        }
      });
    }
  }

  void _onSelectDestination(LatLng location, String name) {
    setState(() {
      _destinationPosition = location;
      _destinationName = name;

      _routePoints = _routeParser.generateRouteWaypoints(_currentPosition, location);
      final distKm = _routeParser.calculateDistanceKm(_currentPosition, location);
      _routeDistance = '${distKm.toStringAsFixed(1)} km';
      final minutes = (distKm / 30.0 * 60.0).round();
      _routeDuration = '$minutes mins';
    });

    _mapController.centerOn(location, zoom: 14);
  }

  void _clearRoute() {
    setState(() {
      _destinationPosition = null;
      _destinationName = null;
      _routePoints = [];
    });
  }

  void _recenterLocation() {
    _mapController.centerOn(_currentPosition, zoom: 14);
  }

  @override
  void dispose() {
    _mbtilesManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Map Layer (100% Offline Vector MBTiles)
            if (_mbtilesReady)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  initialZoom: 13,
                  onTap: (_, point) {
                    _onSelectDestination(point, 'Selected Location');
                  },
                ),
                children: [
                  VectorTileLayer(
                    theme: vtr.ProvidedThemes.lightTheme(),
                    tileProviders: TileProviders({
                      'openmaptiles': _mbtilesManager.provider,
                    }),
                  ),

                  // Route Polyline
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 5.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),

                  // Markers Layer
                  MarkerLayer(
                    markers: [
                      // Current Position Marker
                      Marker(
                        point: _currentPosition,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 26,
                          ),
                        ),
                      ),

                      // Destination Marker
                      if (_destinationPosition != null)
                        Marker(
                          point: _destinationPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 38,
                          ),
                        ),

                      // POI Markers
                      ..._pois.map((poi) {
                        final pos = LatLng(
                          (poi['latitude'] as num).toDouble(),
                          (poi['longitude'] as num).toDouble(),
                        );
                        return Marker(
                          point: pos,
                          width: 32,
                          height: 32,
                          child: GestureDetector(
                            onTap: () {
                              _onSelectDestination(pos, poi['name'] as String);
                            },
                            child: const Icon(
                              Icons.place,
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_initError == null) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Loading Offline Vector Map...'),
                      ] else ...[
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Offline Map Error:\n$_initError',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initOfflineMap,
                          child: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Top Search Bar
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: SearchOverlay(
                onSearchResultSelected: _onSelectDestination,
              ),
            ),

            // Map Control (Recenter)
            Positioned(
              right: 12,
              bottom: _destinationPosition != null ? 180 : 24,
              child: FloatingActionButton.small(
                heroTag: 'recenter',
                backgroundColor: Colors.white,
                onPressed: _recenterLocation,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.black87,
                ),
              ),
            ),

            // Bottom Navigation Panel
            if (_destinationPosition != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: NavigationPanel(
                  destinationName: _destinationName ?? 'Destination',
                  distance: _routeDistance,
                  duration: _routeDuration,
                  onStopNavigation: _clearRoute,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
