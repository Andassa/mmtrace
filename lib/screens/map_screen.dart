import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/bcmm_theme.dart';
import 'permit_details_screen.dart';

/// Carte allégée : peu de polygones, états de chargement, fiche claire au tap.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _center = LatLng(-18.8792, 47.5079);
  static const _limit = 80;

  final _mapController = MapController();
  List<List<LatLng>> _polygons = [];
  List<Map<String, dynamic>> _polygonData = [];
  bool _loading = true;
  String? _error;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _fetchPermis();
  }

  Future<void> _fetchPermis() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        ApiConfig.uri('/api/utilisateur/getPermisGeometries?limit=$_limit'),
        headers: ApiConfig.jsonHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded is List
          ? decoded
          : (decoded is Map && decoded['features'] is List)
              ? decoded['features'] as List<dynamic>
              : <dynamic>[];

      final polys = <List<LatLng>>[];
      final meta = <Map<String, dynamic>>[];

      for (final item in data) {
        if (item is! Map) continue;
        final raw = item['geom'];
        if (raw == null) continue;
        final geometry = raw is String ? json.decode(raw) : raw;
        if (geometry is! Map || geometry['type'] != 'MultiPolygon') continue;
        final coordinates = geometry['coordinates'];
        if (coordinates is! List || coordinates.isEmpty) continue;

        final ring = coordinates[0][0] as List;
        final points = <LatLng>[];
        for (final point in ring) {
          if (point is List && point.length >= 2) {
            points.add(LatLng(
              double.parse(point[1].toString()),
              double.parse(point[0].toString()),
            ));
          }
        }
        if (points.length >= 3) {
          polys.add(points);
          meta.add(Map<String, dynamic>.from(item));
        }
      }

      if (!mounted) return;
      setState(() {
        _polygons = polys;
        _polygonData = meta;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger les permis. Vérifiez le réseau.';
      });
    }
  }

  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;
      final intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude < (xj - xi) * (point.latitude - yi) / ((yj - yi) == 0 ? 1e-12 : (yj - yi)) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  void _onMapTap(TapPosition _, LatLng point) {
    for (var i = 0; i < _polygons.length; i++) {
      if (_pointInPolygon(point, _polygons[i])) {
        setState(() => _selectedIndex = i);
        _openSheet(_polygonData[i]);
        return;
      }
    }
    setState(() => _selectedIndex = null);
  }

  void _openSheet(Map<String, dynamic> data) {
    final titre = (data['titre'] ?? data['titres_no_'] ?? data['gid'] ?? 'Permis').toString();
    final titulaire = (data['registre_1'] ?? data['r_nom'] ?? 'Non renseigné').toString();
    final type = (data['type_tit_1'] ?? data['type'] ?? 'Type inconnu').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Bcmm.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Bcmm.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Permis sélectionné',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Bcmm.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titre,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Bcmm.title,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Titulaire', value: titulaire),
                const SizedBox(height: 8),
                _InfoRow(label: 'Type', value: type),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PermitDetailsScreen(permitData: data),
                      ),
                    );
                  },
                  child: const Text('Voir la fiche'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bcmm.canvas,
      appBar: AppBar(
        title: const Text('Carte des permis'),
        actions: [
          IconButton(
            tooltip: 'Recharger',
            onPressed: _loading ? null : _fetchPermis,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 6.2,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mmtrace',
              ),
              PolygonLayer(
                polygons: [
                  for (var i = 0; i < _polygons.length; i++)
                    Polygon(
                      points: _polygons[i],
                      color: (i == _selectedIndex ? Bcmm.primary : Bcmm.primary).withOpacity(i == _selectedIndex ? 0.45 : 0.22),
                      borderColor: Bcmm.primary,
                      borderStrokeWidth: i == _selectedIndex ? 2.5 : 1.2,
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Bcmm.card,
                border: Border.all(color: Bcmm.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _loading
                    ? 'Chargement des permis…'
                    : _error ??
                        'Touchez un polygone bleu pour voir le permis. Affichage limité à $_limit titres (performance).',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  height: 1.35,
                  color: _error != null ? Bcmm.danger : Bcmm.body,
                ),
              ),
            ),
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Bcmm.primary),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Bcmm.muted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Bcmm.title,
            ),
          ),
        ),
      ],
    );
  }
}
