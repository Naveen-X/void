import 'package:flutter/material.dart';

/// Design constants for consistent UI across the app
class VoidDesign {
  VoidDesign._();

  // ──────────────────────────────────────────────────────────────────────────
  // SPACING
  // ──────────────────────────────────────────────────────────────────────────
  
  /// Extra small spacing - 4.0
  static const double spaceXS = 4.0;
  
  /// Small spacing - 8.0
  static const double spaceSM = 8.0;
  
  /// Medium spacing - 12.0
  static const double spaceMD = 12.0;
  
  /// Large spacing - 16.0
  static const double spaceLG = 16.0;
  
  /// Extra large spacing - 24.0
  static const double spaceXL = 24.0;
  
  /// Double extra large spacing - 32.0
  static const double space2XL = 32.0;
  
  /// Triple extra large spacing - 48.0
  static const double space3XL = 48.0;

  // ──────────────────────────────────────────────────────────────────────────
  // PADDING
  // ──────────────────────────────────────────────────────────────────────────
  
  /// Standard page horizontal padding
  static const double pageHorizontal = 20.0;
  
  /// Standard card padding
  static const double cardPadding = 14.0;
  
  /// Standard section padding
  static const double sectionPadding = 16.0;

  // ──────────────────────────────────────────────────────────────────────────
  // BORDER RADIUS
  // ──────────────────────────────────────────────────────────────────────────
  
  /// Small radius - 8
  static const double radiusSM = 8.0;
  
  /// Medium radius - 12
  static const double radiusMD = 12.0;
  
  /// Large radius - 16
  static const double radiusLG = 16.0;
  
  /// Extra large radius - 20
  static const double radiusXL = 20.0;
  
  /// Card radius
  static const double radiusCard = 18.0;
  
  /// Pill/chip radius
  static const double radiusPill = 30.0;

  // ──────────────────────────────────────────────────────────────────────────
  // COLORS
  // ──────────────────────────────────────────────────────────────────────────
  
  // PRIMARY COLORS are now accessed via VoidTheme.of(context)
  // Retaining these currently for reference during refactor, but they should be replaced.
  
  // ──────────────────────────────────────────────────────────────────────────
  // ANIMATION DURATIONS
  // ──────────────────────────────────────────────────────────────────────────
  
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
  static const Duration animPage = Duration(milliseconds: 500);

  // ──────────────────────────────────────────────────────────────────────────
  // SHADOWS
  // ──────────────────────────────────────────────────────────────────────────
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get softGlow => [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.05),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // TYPE-SPECIFIC COLORS
  // ──────────────────────────────────────────────────────────────────────────
  
  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'link':
        return Colors.blueAccent;
      case 'note':
        return Colors.white70; // This might need to be dynamic later
      case 'image':
        return Colors.tealAccent;
      case 'pdf':
        return Colors.redAccent;
      case 'document':
        return Colors.orangeAccent;
      case 'video':
        return Colors.purpleAccent;
      case 'file':
        return Colors.grey;
      default:
        return Colors.white54;
    }
  }
  
  /// Get an icon for the item type
  static IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'link':
        return Icons.link_rounded;
      case 'note':
        return Icons.notes_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'document':
        return Icons.description_rounded;
      case 'video':
        return Icons.video_file_rounded;
      case 'file':
        return Icons.insert_drive_file_rounded;
      default:
        return Icons.circle;
    }
  }
}
