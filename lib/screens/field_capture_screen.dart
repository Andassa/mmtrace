import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_client.dart';

/// Capture terrain : GPS + substance + note + photo → sync API.
class FieldCaptureScreen extends StatefulWidget {
  const FieldCaptureScreen({super.key});

  @override
  State<FieldCaptureScreen> createState() => _FieldCaptureScreenState();
}

class _FieldCaptureScreenState extends State<FieldCaptureScreen> {
  final _substanceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _picker = ImagePicker();
  File? _photo;
  double? _lon;
  double? _lat;
  bool _loading = false;
  String _status = '';
  final List<Map<String, dynamic>> _queue = [];

  Future<void> _locate() async {
    setState(() {
      _loading = true;
      _status = 'Localisation…';
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => _status = 'Activez le GPS');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => _status = 'Permission localisation refusée');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _lon = pos.longitude;
        _lat = pos.latitude;
        _status = 'GPS OK: ${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}';
      });
    } catch (e) {
      setState(() => _status = 'Erreur GPS: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _takePhoto() async {
    final shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1600);
    if (shot != null) {
      setState(() => _photo = File(shot.path));
    }
  }

  Future<void> _syncOne(Map<String, dynamic> payload) async {
    final res = await ApiClient.instance.post('/api/terrain/sync', payload);
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['erreur'] ?? 'HTTP ${res.statusCode}');
    }
  }

  Future<void> _saveLocalThenSync() async {
    if (_lon == null || _lat == null) {
      setState(() => _status = 'GPS requis');
      return;
    }
    if (_substanceCtrl.text.trim().isEmpty) {
      setState(() => _status = 'Substance requise');
      return;
    }

    String? photoBase64;
    if (_photo != null) {
      final bytes = await _photo!.readAsBytes();
      photoBase64 = base64Encode(bytes);
    }

    final payload = {
      'substance': _substanceCtrl.text.trim(),
      'note': _noteCtrl.text.trim(),
      'lon': _lon,
      'lat': _lat,
      if (photoBase64 != null) 'photoBase64': photoBase64,
      'meta': {'source': 'mmtrace_field', 'offlineQueued': false},
    };

    setState(() {
      _loading = true;
      _status = 'Synchronisation…';
    });

    try {
      if (!ApiClient.instance.hasSession) {
        _queue.add(payload);
        setState(() => _status = 'Hors session — observation mise en file (${_queue.length}). Reconnectez-vous puis « Vider la file ».');
        return;
      }
      await _syncOne(payload);
      setState(() {
        _status = 'Observation synchronisée';
        _photo = null;
        _noteCtrl.clear();
      });
    } catch (e) {
      _queue.add(payload);
      setState(() => _status = 'Échec sync — mis en file (${_queue.length}): $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _flushQueue() async {
    if (_queue.isEmpty) {
      setState(() => _status = 'File vide');
      return;
    }
    setState(() => _loading = true);
    var ok = 0;
    final remaining = <Map<String, dynamic>>[];
    for (final item in List.of(_queue)) {
      try {
        await _syncOne(item);
        ok++;
      } catch (_) {
        remaining.add(item);
      }
    }
    setState(() {
      _queue
        ..clear()
        ..addAll(remaining);
      _status = 'Sync file: $ok OK, ${remaining.length} restant(s)';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _substanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture terrain')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Collecte GPS + photo → API Mineral Mapping', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _substanceCtrl,
            decoration: const InputDecoration(labelText: 'Substance', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Note terrain', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          if (_photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_photo!, height: 180, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(onPressed: _loading ? null : _locate, icon: const Icon(Icons.my_location), label: const Text('GPS')),
              ElevatedButton.icon(onPressed: _loading ? null : _takePhoto, icon: const Icon(Icons.camera_alt), label: const Text('Photo')),
              ElevatedButton.icon(onPressed: _loading ? null : _saveLocalThenSync, icon: const Icon(Icons.cloud_upload), label: const Text('Sync')),
              OutlinedButton(onPressed: _loading ? null : _flushQueue, child: Text('Vider file (${_queue.length})')),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading) const LinearProgressIndicator(),
          Text(_status, style: TextStyle(color: Colors.blueGrey[800])),
        ],
      ),
    );
  }
}
