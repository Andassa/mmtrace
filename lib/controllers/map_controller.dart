import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class PermitController {
  Future<List<List<LatLng>>> getPermitPolygons() async {
    final response = await http.get(Uri.parse('http://localhost:3001/getPolygons'));

    if (response.statusCode == 200) {
      // Assurez-vous que 'data' est un List contenant des listes de coordonnées
      List<dynamic> data = json.decode(response.body);

      // Convertir chaque polygone en List<LatLng>
      return data.map((polygon) {
        return List<LatLng>.from(polygon.map((coord) {
          return LatLng(coord['lat'], coord['lng']);
        }));
      }).toList();
    } else {
      throw Exception('Failed to load polygons');
    }
  }
}
