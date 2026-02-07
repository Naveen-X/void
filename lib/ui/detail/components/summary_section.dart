// lib/ui/detail/components/summary_section.dart
// Summary section with AI context generation

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/services/groq_service.dart';

class SummarySection extends StatelessWidget {
  final VoidItem item;
  final bool isGenerating;
  final VoidCallback onGenerate;

  const SummarySection({
    super.key,
    required this.item,
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'SUMMARY',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            if (GroqService.isConfigured)
              GestureDetector(
                onTap: onGenerate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.cyanAccent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      if (isGenerating)
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.cyanAccent,
                          ),
                        )
                      else
                        const Icon(Icons.auto_awesome_rounded,
                            size: 10, color: Colors.cyanAccent),
                      const SizedBox(width: 6),
                      Text(
                        isGenerating ? 'THINKING...' : 'REFRESH',
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.cyanAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (item.tldr?.isNotEmpty ?? false) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: Colors.cyanAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'TL;DR',
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.cyanAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.tldr ?? '',
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (item.summary?.isNotEmpty ?? false)
          Text(
            item.summary ?? '',
            style: GoogleFonts.ibmPlexSans(
              color: Colors.white70,
              fontSize: 15,
              height: 1.7,
            ),
          ),
      ],
    );
  }
}
