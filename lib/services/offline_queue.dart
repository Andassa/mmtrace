import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueue {
  static const _key = 'mmtrace_terrain_queue_v1';

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> save(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  static Future<void> enqueue(Map<String, dynamic> item) async {
    final items = await load();
    items.add({...item, 'queuedAt': DateTime.now().toIso8601String()});
    await save(items);
  }

  static Future<void> replaceAll(List<Map<String, dynamic>> items) async {
    await save(items);
  }
}
