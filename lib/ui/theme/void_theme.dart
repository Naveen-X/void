import 'package:flutter/material.dart';

class VoidTheme {
  final Color bgPrimary;
  final Color bgCard;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color borderSubtle;
  final Color borderMedium;
  final Brightness brightness;

  const VoidTheme({
    required this.bgPrimary,
    required this.bgCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.borderSubtle,
    required this.borderMedium,
    required this.brightness,
  });

  static VoidTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }

  static final VoidTheme dark = VoidTheme(
    bgPrimary: Colors.black,
    bgCard: const Color(0xFF111111),
    textPrimary: Colors.white,
    textSecondary: Colors.white.withValues(alpha: 0.7),
    textTertiary: Colors.white.withValues(alpha: 0.4),
    textMuted: Colors.white.withValues(alpha: 0.25),
    borderSubtle: Colors.white.withValues(alpha: 0.08),
    borderMedium: Colors.white.withValues(alpha: 0.12),
    brightness: Brightness.dark,
  );

  static final VoidTheme light = VoidTheme(
    bgPrimary: const Color(0xFFF2F2F7), // iOS-like light gray
    bgCard: const Color(0xFFFFFFFF),
    textPrimary: Colors.black,
    textSecondary: Colors.black.withValues(alpha: 0.7),
    textTertiary: Colors.black.withValues(alpha: 0.4),
    textMuted: Colors.black.withValues(alpha: 0.25),
    borderSubtle: Colors.black.withValues(alpha: 0.08),
    borderMedium: Colors.black.withValues(alpha: 0.12),
    brightness: Brightness.light,
  );
}
