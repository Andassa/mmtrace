import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = LatLng(-18.8792, 47.5079); // Coordonnées d'exemple
  final double _zoom = 13.0; // Niveau de zoom initial

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des Permis Miniers'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center, // Position initiale
          initialZoom: _zoom,     // Niveau de zoom initial
          interactionOptions: const InteractionOptions(
            flags: ~InteractiveFlag.doubleTapZoom,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mmtrace', // Ton nom de package
          ),
        ],
      ),
    );
  }
}

