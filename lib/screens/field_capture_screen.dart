import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_client.dart';
import '../services/offline_queue.dart';

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
  List<Map<String, dynamic>> _queue = [];
  List<Map<String, dynamic>> _serverObs = [];

  @override
  void initState() {
    super.initState();
    _reloadQueue();
    _loadServerObs();
  }

  Future<void> _reloadQueue() async {
    final q = await OfflineQueue.load();
    setState(() => _queue = q);
  }

  Future<void> _loadServerObs() async {
    try {
      final res = await ApiClient.instance.get('/api/terrain/observations?limit=30');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _serverObs = List<Map<String, dynamic>>.from((data['observations'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
        });
      }
    } catch (_) {}
  }

  Future<void> _locate() async {
    setState(() {
      _loading = true;
      _status = 'Localisation…';
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
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
    if (shot != null) setState(() => _photo = File(shot.path));
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
      photoBase64 = base64Encode(await _photo!.readAsBytes());
    }

    final payload = {
      'substance': _substanceCtrl.text.trim(),
      'note': _noteCtrl.text.trim(),
      'lon': _lon,
      'lat': _lat,
      if (photoBase64 != null) 'photoBase64': photoBase64,
      'meta': {'source': 'mmtrace_field'},
    };

    setState(() {
      _loading = true;
      _status = 'Synchronisation…';
    });

    try {
      if (!ApiClient.instance.hasSession) {
        await OfflineQueue.enqueue(payload);
        await _reloadQueue();
        setState(() => _status = 'Hors session — sauvé offline (${_queue.length})');
        return;
      }
      await _syncOne(payload);
      setState(() {
        _status = 'Observation synchronisée';
        _photo = null;
        _noteCtrl.clear();
      });
      await _loadServerObs();
    } catch (e) {
      await OfflineQueue.enqueue(payload);
      await _reloadQueue();
      setState(() => _status = 'Échec réseau — offline (${_queue.length}): $e');
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
    final remaining = <Map<String, dynamic>>[];
    var ok = 0;
    for (final item in List.of(_queue)) {
      try {
        await _syncOne(item);
        ok++;
      } catch (_) {
        remaining.add(item);
      }
    }
    await OfflineQueue.replaceAll(remaining);
    await _reloadQueue();
    await _loadServerObs();
    setState(() {
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
          const Text('GPS + photo · file offline persistante · sync API'),
          const SizedBox(height: 12),
          TextField(controller: _substanceCtrl, decoration: const InputDecoration(labelText: 'Substance', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _noteCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          if (_photo != null) Image.file(_photo!, height: 160, fit: BoxFit.cover),
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
          if (_loading) const LinearProgressIndicator(),
          Text(_status),
          const Divider(),
          Text('File offline', style: Theme.of(context).textTheme.titleMedium),
          ..._queue.map((q) => ListTile(
                dense: true,
                title: Text('${q['substance']}'),
                subtitle: Text('${q['lat']}, ${q['lon']} · ${q['queuedAt'] ?? ''}'),
              )),
          if (_queue.isEmpty) const Text('Aucune observation en attente'),
          const Divider(),
          Text('Dernières obs serveur', style: Theme.of(context).textTheme.titleMedium),
          ..._serverObs.map((o) => ListTile(
                dense: true,
                title: Text('${o['substance'] ?? '—'}'),
                subtitle: Text('id=${o['id']} · ${o['lat']}, ${o['lon']}'),
              )),
        ],
      ),
    );
  }
}
