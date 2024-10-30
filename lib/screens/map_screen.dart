import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mmtrace/screens/permit_tracking_screen.dart';
import 'permit_details_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<List<LatLng>> _polygons = [];
  final LatLng _center = LatLng(-18.8792, 47.5079);
  final double _zoom = 6.0;
  List<Map<String, dynamic>> _polygonData = [];

  @override
  void initState() {
    super.initState();
    _fetchPermisGeometries();
  }

  Future<void> _fetchPermisGeometries() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.88.69:3000/api/utilisateur/getPermisGeometries'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _polygons = [];
          for (var item in data) {
            if (item['geom'] != null) {
              final geometry = json.decode(item['geom']);
              final coordinates = geometry['coordinates'];

              if (geometry['type'] == 'MultiPolygon' && coordinates is List) {
                List<LatLng> polygonPoints = [];

                for (var polygon in coordinates) {
                  var points = polygon[0].map<LatLng>((point) {
                    if (point is List && point.length >= 2) {
                      return LatLng(
                        double.parse(point[1].toString()),  // latitude
                        double.parse(point[0].toString()),  // longitude
                      );
                    }
                    return LatLng(0, 0); // Valeur par défaut
                  }).toList();

                  polygonPoints.addAll(points);
                }

                _polygons.add(polygonPoints);
              }
            }
          }

          _polygonData = data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Erreur : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur : ${e.toString()}');
    }
  }

  void _showPolygonInfo(BuildContext context, Map<String, dynamic> polygonData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Info sur le polygone'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ...polygonData.entries.map((entry) {
                  return Text('${entry.key}: ${entry.value}');
                }).toList(),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PermitDetailsScreen(permitData: polygonData),
                      ),
                    );
                  },
                  child: Text('Voir détails du permis', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PermitTrackingScreen(),
                      ),
                    );
                  },
                  child: Text('Suivi du permis', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].longitude > point.longitude) != (polygon[j].longitude > point.longitude) &&
          (point.latitude < (polygon[j].latitude - polygon[i].latitude) * (point.longitude - polygon[i].longitude) /
              (polygon[j].longitude - polygon[i].longitude) + polygon[i].latitude)) {
        inside = !inside;
      }
    }
    return inside;
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
          onTap: (tapPosition, point) {
            for (int i = 0; i < _polygons.length; i++) {
              if (isPointInPolygon(point, _polygons[i])) {
                _showPolygonInfo(context, _polygonData[i]);
                break;
              }
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mmtrace',
          ),
          PolygonLayer(
            polygons: _polygons.map<Polygon>((points) {
              return Polygon(
                points: points,
                color: Colors.blue.withOpacity(0.3),
                borderColor: Colors.blue,
                borderStrokeWidth: 3,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
