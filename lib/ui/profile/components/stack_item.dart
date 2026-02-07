// lib/ui/profile/components/stack_item.dart
// Tech stack progress item widget

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A progress bar widget for displaying tech stack items
class StackItem extends StatelessWidget {
  final String label;
  final String? version;
  final double progress;
  final bool isCompact;

  const StackItem({
    super.key,
    required this.label,
    this.version,
    required this.progress,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactLayout();
    }
    return _buildStandardLayout();
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
            if (version != null)
              Text(
                version!,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  color: Colors.cyanAccent.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardLayout() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
