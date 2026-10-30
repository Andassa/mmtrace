import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/bcmm_theme.dart';
import 'field_capture_screen.dart';
import 'map_screen.dart';

/// Accueil terrain BCMM : une seule question = "que faire maintenant ?"
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bcmm.canvas,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/bcmm.png',
              height: 28,
              errorBuilder: (_, __, ___) => Text(
                'BCMM',
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.w800,
                  color: Bcmm.primary,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Terrain',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Bcmm.title,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'Que voulez-vous faire ?',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Bcmm.title,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Application terrain Mineral Mapping. Compte interne BCMM.',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              color: Bcmm.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Iconsax.gps,
            title: 'Capturer une observation',
            subtitle: 'GPS, photo, substance. File offline si pas de réseau.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FieldCaptureScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Iconsax.map_1,
            title: 'Voir la carte des permis',
            subtitle: 'Repérer un titre minier près de votre position.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Rappel',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Bcmm.muted,
              letterSpacing: 0.02,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Bcmm.card,
              border: Border.all(color: Bcmm.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '1. Activez le GPS.\n'
              '2. Capturez sur Terrain (onglet du bas).\n'
              '3. Si hors ligne, la file se synchronise plus tard.',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                height: 1.5,
                color: Bcmm.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Bcmm.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Bcmm.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Bcmm.primary, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Bcmm.title,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        color: Bcmm.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Bcmm.muted),
            ],
          ),
        ),
      ),
    );
  }
}
