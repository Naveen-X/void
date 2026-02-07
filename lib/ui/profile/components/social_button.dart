// lib/ui/profile/components/social_button.dart
// Reusable social media link button

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/haptic_service.dart';
import '../../theme/void_theme.dart';

/// A button for social media links with blur effect
class SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final bool isFullWidth;
  final bool centerContent;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
    this.isFullWidth = false,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    return GestureDetector(
      onTap: () async {
        HapticService.light();
        final uri = Uri.parse(url);
        try {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            debugPrint("Could not launch $url");
          }
        } catch (e) {
          debugPrint("Error launching URL: $e");
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: (isFullWidth || centerContent)
                ? Alignment.center
                : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: (isFullWidth || centerContent)
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, size: 18, color: theme.textSecondary),
                if (!isFullWidth) const SizedBox(width: 12),
                if (isFullWidth) const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 13,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
