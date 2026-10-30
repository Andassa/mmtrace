import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../config/api_config.dart';

class PermitController {
  Future<List<List<LatLng>>> getPermitPolygons() async {
    final response = await http.get(
      ApiConfig.uri('/api/utilisateur/getPermisGeometries?limit=300'),
      headers: ApiConfig.jsonHeaders(),
    );

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      final List<dynamic> data = decoded is List
          ? decoded
          : (decoded is Map && decoded['features'] is List)
              ? decoded['features'] as List<dynamic>
              : <dynamic>[];

      return data.map((item) {
        if (item['geom'] == null) return <LatLng>[];
        final geometry = item['geom'] is String ? json.decode(item['geom']) : item['geom'];
        final coordinates = geometry['coordinates'];
        if (geometry['type'] != 'MultiPolygon' || coordinates is! List) {
          return <LatLng>[];
        }
        final points = <LatLng>[];
        for (final polygon in coordinates) {
          for (final point in polygon[0]) {
            if (point is List && point.length >= 2) {
              points.add(LatLng(
                double.parse(point[1].toString()),
                double.parse(point[0].toString()),
              ));
            }
          }
        }
        return points;
      }).toList();
    } else {
      throw Exception('Failed to load polygons');
    }
  }
}
