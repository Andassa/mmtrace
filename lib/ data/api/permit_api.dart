/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mmtrace/ data/models/permit_model.dart';

class PermitAPI {
  final String apiUrl = "https://api.example.com/permits";

  Future<List<Permit>> fetchPermits() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> permitsJson = json.decode(response.body);
      return permitsJson.map((json) => Permit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load permits');
    }
  }
}
*/