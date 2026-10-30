import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_client.dart';
import '../services/offline_queue.dart';
import '../theme/bcmm_theme.dart';
import '../widgets/bcmm_ui.dart';

/// Accueil type inspection (OpenGov / Scharf) : statut + liste d'actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenTerrain,
    required this.onOpenMap,
  });

  final VoidCallback onOpenTerrain;
  final VoidCallback onOpenMap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final q = await OfflineQueue.load();
    if (mounted) setState(() => _pending = q.length);
  }

  @override
  Widget build(BuildContext context) {
    String today;
    try {
      today = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now());
    } catch (_) {
      today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    final online = ApiClient.instance.hasSession;

    return Scaffold(
      backgroundColor: Bcmm.canvas,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/bcmm.png',
              height: 26,
              errorBuilder: (_, __, ___) => Text(
                'BCMM',
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.w700,
                  color: Bcmm.primary,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Terrain'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: Bcmm.primary,
        onRefresh: _loadPending,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                color: Bcmm.card,
                border: Border(bottom: BorderSide(color: Bcmm.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    today.isEmpty
                        ? ''
                        : '${today[0].toUpperCase()}${today.substring(1)}',
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, color: Bcmm.muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Session de terrain',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Bcmm.title,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      BcmmStatusChip(
                        label: online ? 'Session active' : 'Hors session',
                        ok: online,
                        pending: !online,
                      ),
                      BcmmStatusChip(
                        label: _pending == 0 ? 'Rien à synchroniser' : '$_pending à synchroniser',
                        ok: _pending == 0,
                        pending: _pending > 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: BcmmSectionLabel('Travail'),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Bcmm.border),
                  bottom: BorderSide(color: Bcmm.border),
                ),
              ),
              child: Column(
                children: [
                  BcmmMenuRow(
                    title: 'Nouvelle observation',
                    subtitle: 'GPS, substance, photo, envoi',
                    onTap: widget.onOpenTerrain,
                  ),
                  BcmmMenuRow(
                    title: 'Carte des permis',
                    subtitle: 'Consulter un titre sur la carte',
                    onTap: widget.onOpenMap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: BcmmSectionLabel('Procédure'),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: Bcmm.card,
                border: Border(
                  top: BorderSide(color: Bcmm.border),
                  bottom: BorderSide(color: Bcmm.border),
                ),
              ),
              child: Text(
                'Sur le terrain : positionnez le GPS, saisissez la substance, '
                'ajoutez une photo si besoin, puis synchronisez. '
                'Sans réseau, les saisies restent en file locale.',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  height: 1.45,
                  color: Bcmm.body,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
