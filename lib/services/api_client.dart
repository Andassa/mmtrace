import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Client HTTP avec cookie de session (auth Passport).
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _cookie;

  Map<String, String> _headers({bool flutterAgent = true}) {
    return {
      ...ApiConfig.jsonHeaders(flutterAgent: flutterAgent),
      if (_cookie != null) 'Cookie': _cookie!,
    };
  }

  void _captureCookies(http.Response response) {
    final raw = response.headers['set-cookie'];
    if (raw == null || raw.isEmpty) return;
    // Garder connect.sid=...
    final first = raw.split(',').first.split(';').first.trim();
    if (first.contains('=')) {
      _cookie = first;
    }
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      ApiConfig.uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _captureCookies(response);
    return response;
  }

  Future<http.Response> get(String path) async {
    final response = await http.get(
      ApiConfig.uri(path),
      headers: _headers(),
    );
    _captureCookies(response);
    return response;
  }

  bool get hasSession => _cookie != null && _cookie!.isNotEmpty;
}
