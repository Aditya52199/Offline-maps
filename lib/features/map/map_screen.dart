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
        children: [
          // Offline MBTiles tile layer served locally
          TileLayer(
            urlTemplate: 'http://localhost:8080/styles/basic/{z}/{x}/{y}.png',
            maxZoom: 18,
          ),
          const RichAttributionWidget(
            attributions: const [
              TextSourceAttribution('Offline map placeholder'),
            ],
          ),
        ],
      ),
    );
  }
}
