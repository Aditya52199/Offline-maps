import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline GPS')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(23.2599, 77.4126),
          initialZoom: 12,
        ),
        children: const [
          // TODO: Replace with the offline MBTiles tile layer.
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution('Offline map placeholder'),
            ],
          ),
        ],
      ),
    );
  }
}
