// lib/ui/detail/components/detail_metadata.dart
// Metadata row and inline tags

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/ui/theme/void_theme.dart';
import 'package:void_space/ui/utils/type_helpers.dart';
import 'tag_dialog.dart';

class DetailMetadata extends StatelessWidget {
  final VoidItem item;
  final List<String> tags;
  final Function(String) onAddTag;
  final Function(String) onRemoveTag;
  final Function(List<String>) onSaveTags; // For saving after removal

  const DetailMetadata({
    super.key,
    required this.item,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSaveTags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    final typeColor = getColorForType(item.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: typeColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(getIconForType(item.type), size: 14, color: typeColor),
                  const SizedBox(width: 6),
                  Text(
                    item.type.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Date info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.textPrimary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.textPrimary.withValues(alpha: 0.06)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12, color: theme.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    formatLivingDate(item.createdAt),
                    style: GoogleFonts.ibmPlexMono(
                      color: theme.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Existing tags with remove on long press
            ...tags.map((tag) => GestureDetector(
                  onLongPress: () async {
                    HapticService.warning();
                    onRemoveTag(tag);
                    onSaveTags(List.from(tags)..remove(tag)); // Logic handled in parent, this is just trigger
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          typeColor.withValues(alpha: 0.12),
                          typeColor.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: typeColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.ibmPlexMono(
                        color: theme.brightness == Brightness.dark 
                           ? typeColor.withValues(alpha: 0.9)
                           : typeColor.withValues(alpha: 1.0),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
            // Add tag button
            GestureDetector(
              onTap: () => TagDialog.show(context, onAddTag),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.textPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: theme.textPrimary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: theme.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'ADD TAG',
                      style: GoogleFonts.ibmPlexMono(
                        color: theme.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
