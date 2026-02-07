// lib/ui/detail/components/detail_actions.dart
// Action buttons like Open File

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/ui/utils/type_helpers.dart';

class DetailActions {
  static Widget buildOpenFileButton(VoidItem item, VoidCallback onTap) {
    String label;
    switch (item.type) {
      case 'image':
        label = 'VIEW IMAGE';
        break;
      case 'pdf':
        label = 'OPEN PDF';
        break;
      case 'document':
        label = 'OPEN DOCUMENT';
        break;
      case 'video':
        label = 'PLAY VIDEO';
        break;
      default:
        label = 'OPEN FILE';
    }

    final typeColor = getColorForType(item.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              typeColor.withValues(alpha: 0.15),
              typeColor.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: typeColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(getIconForType(item.type), color: typeColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.ibmPlexMono(
                color: typeColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
