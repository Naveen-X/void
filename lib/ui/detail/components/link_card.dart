// lib/ui/detail/components/link_card.dart
// Card to display link content

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/void_theme.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/services/haptic_service.dart';

class LinkCard extends StatelessWidget {
  final VoidItem item;

  const LinkCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    return GestureDetector(
      onTap: () {
        HapticService.light();
        launchUrl(Uri.parse(item.content));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent.withValues(alpha: 0.08),
              Colors.blueAccent.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.open_in_new_rounded,
                  color: Colors.blueAccent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPEN LINK',
                    style: GoogleFonts.ibmPlexMono(
                      color: Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexMono(
                      color: theme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.blueAccent.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
