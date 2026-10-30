import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_client.dart';
import '../services/offline_queue.dart';
import '../theme/bcmm_theme.dart';
import '../widgets/bcmm_ui.dart';

/// Capture observation : flux inspection (GPS → détails → preuve → envoi).
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

  bool get _gpsOk => _lon != null && _lat != null;

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
      final res = await ApiClient.instance.get('/api/terrain/observations?limit=20');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _serverObs = List<Map<String, dynamic>>.from(
            (data['observations'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _locate() async {
    setState(() {
      _loading = true;
      _status = 'Localisation en cours…';
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _status = 'Activez le GPS du téléphone.');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => _status = 'Permission de localisation refusée.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _lon = pos.longitude;
        _lat = pos.latitude;
        _status = 'Position enregistrée.';
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
    if (!_gpsOk) {
      setState(() => _status = 'Position GPS requise.');
      return;
    }
    if (_substanceCtrl.text.trim().isEmpty) {
      setState(() => _status = 'Substance requise.');
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
      _status = 'Envoi…';
    });

    try {
      if (!ApiClient.instance.hasSession) {
        await OfflineQueue.enqueue(payload);
        await _reloadQueue();
        setState(() => _status = 'Hors session. Sauvé en file locale (${_queue.length}).');
        return;
      }
      await _syncOne(payload);
      setState(() {
        _status = 'Observation envoyée.';
        _photo = null;
        _noteCtrl.clear();
      });
      await _loadServerObs();
    } catch (e) {
      await OfflineQueue.enqueue(payload);
      await _reloadQueue();
      setState(() => _status = 'Réseau indisponible. Mis en file (${_queue.length}).');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _flushQueue() async {
    if (_queue.isEmpty) {
      setState(() => _status = 'File déjà vide.');
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
      _status = 'Synchronisation: $ok ok, ${remaining.length} restant(s).';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _substanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Widget _panel({required Widget child, Border? border}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Bcmm.card,
        border: border ??
            const Border.symmetric(
              horizontal: BorderSide(color: Bcmm.border),
            ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bcmm.canvas,
      appBar: AppBar(
        title: const Text('Observation'),
        actions: [
          if (_queue.isNotEmpty)
            TextButton(
              onPressed: _loading ? null : _flushQueue,
              child: Text('Sync (${_queue.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: const BoxDecoration(
                    color: Bcmm.card,
                    border: Border(bottom: BorderSide(color: Bcmm.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _StepBadge(n: '1', label: 'GPS', done: _gpsOk)),
                      Expanded(
                        child: _StepBadge(
                          n: '2',
                          label: 'Détails',
                          done: _substanceCtrl.text.trim().isNotEmpty,
                        ),
                      ),
                      Expanded(child: _StepBadge(n: '3', label: 'Photo', done: _photo != null)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: BcmmSectionLabel('Position'),
                ),
                const SizedBox(height: 8),
                _panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _gpsOk
                            ? '${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}'
                            : 'Aucune position',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _gpsOk ? Bcmm.title : Bcmm.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _locate,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: Text(_gpsOk ? 'Actualiser le GPS' : 'Obtenir le GPS'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: BcmmSectionLabel('Détails'),
                ),
                const SizedBox(height: 8),
                _panel(
                  child: Column(
                    children: [
                      TextField(
                        controller: _substanceCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(labelText: 'Substance'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Note (optionnel)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: BcmmSectionLabel('Preuve photo'),
                ),
                const SizedBox(height: 8),
                _panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_photo != null) ...[
                        Image.file(_photo!, height: 160, fit: BoxFit.cover),
                        const SizedBox(height: 12),
                      ],
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _takePhoto,
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: Text(_photo == null ? 'Prendre une photo' : 'Reprendre la photo'),
                      ),
                    ],
                  ),
                ),
                if (_status.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _status,
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Bcmm.body),
                    ),
                  ),
                ],
                if (_queue.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: BcmmSectionLabel('File locale'),
                  ),
                  const SizedBox(height: 8),
                  ..._queue.map(
                    (q) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Bcmm.card,
                        border: Border(bottom: BorderSide(color: Bcmm.border)),
                      ),
                      child: Text(
                        '${q['substance']}  ·  ${q['lat']}, ${q['lon']}',
                        style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Bcmm.body),
                      ),
                    ),
                  ),
                ],
                if (_serverObs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: BcmmSectionLabel('Dernières sur serveur'),
                  ),
                  const SizedBox(height: 8),
                  ..._serverObs.take(5).map(
                    (o) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Bcmm.card,
                        border: Border(bottom: BorderSide(color: Bcmm.border)),
                      ),
                      child: Text(
                        '${o['substance'] ?? 'n/a'}  ·  ${o['lat']}, ${o['lon']}',
                        style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Bcmm.body),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Bcmm.card,
              border: Border(top: BorderSide(color: Bcmm.border)),
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveLocalThenSync,
                child: const Text('Enregistrer et synchroniser'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.n, required this.label, required this.done});
  final String n;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          color: done ? Bcmm.primary : Bcmm.border,
          child: Text(
            done ? '✓' : n,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: done ? Colors.white : Bcmm.muted,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: done ? Bcmm.primary : Bcmm.muted,
            ),
          ),
        ),
      ],
    );
  }
}
