import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<List<LatLng>> _polygons = []; // Liste de listes pour les polygones
  final _center = LatLng(-18.8792, 47.5079); // Centre de Madagascar
  final _zoom = 6.0;

  @override
  void initState() {
    super.initState();
    _fetchPermisGeometries();
  }

  Future<void> _fetchPermisGeometries() async {
    final response = await http.get(Uri.parse('http://192.168.88.69:3000/api/utilisateur/getPermisGeometries'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print("Données reçues : $data");  // Affiche les données dans la console pour vérification

      setState(() {
        // Transformation des données en listes de coordonnées LatLng pour chaque polygone
        _polygons = data.map((item) {
          final List coordinates = item['geom']['coordinates'][0];
          if (coordinates.isNotEmpty) {
            return coordinates.map((point) => LatLng(point[1], point[0])).toList();
          }
          return <LatLng>[];
        }).toList();

        // Affichage des coordonnées pour vérifier
        print("Coordonnées des polygones : $_polygons");
      });
    } else {
      throw Exception('Erreur lors de la récupération des données de permis.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des Permis Miniers'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: _zoom,
          interactionOptions: const InteractionOptions(
            flags: ~InteractiveFlag.doubleTapZoom,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mmtrace',
          ),
          PolygonLayer(
            polygons: _polygons.isNotEmpty
                ? _polygons.map((points) => Polygon(
              points: points,
              color: Colors.blue.withOpacity(0.3),
              borderColor: Colors.blue,
              borderStrokeWidth: 3,
            )).toList()
                : [
              Polygon(
                points: [
                  LatLng(-18.8792, 47.5079),
                  LatLng(-18.8782, 47.5070),
                  LatLng(-18.8785, 47.5080),
                ],
                color: Colors.red.withOpacity(0.5),
                borderColor: Colors.red,
                borderStrokeWidth: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
