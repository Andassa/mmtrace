import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bcmm_theme.dart';

class BcmmSectionLabel extends StatelessWidget {
  const BcmmSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.ibmPlexSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: Bcmm.muted,
      ),
    );
  }
}

class BcmmStatusChip extends StatelessWidget {
  const BcmmStatusChip({
    super.key,
    required this.label,
    required this.ok,
    this.pending = false,
  });

  final String label;
  final bool ok;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final color = pending
        ? Bcmm.warn
        : ok
            ? Bcmm.success
            : Bcmm.muted;
    final bg = pending
        ? const Color(0xFFFFF4E5)
        : ok
            ? const Color(0xFFECFDF3)
            : const Color(0xFFF3F4F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class BcmmMenuRow extends StatelessWidget {
  const BcmmMenuRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: Bcmm.card,
          border: Border(bottom: BorderSide(color: Bcmm.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Bcmm.title,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      color: Bcmm.muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, size: 20, color: Bcmm.muted),
          ],
        ),
      ),
    );
  }
}
