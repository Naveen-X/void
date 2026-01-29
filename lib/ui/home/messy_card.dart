import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/void_item.dart';
import '../../services/haptic_service.dart';
import 'item_detail_screen.dart';

class MessyCard extends StatelessWidget {
  final VoidItem item;
  final VoidCallback onUpdate;
  final bool isSelected;
  final bool isSelectionMode;
  final Function(String) onSelect;
  final FocusNode searchFocusNode; 

  const MessyCard({
    super.key, 
    required this.item, 
    required this.onUpdate,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onSelect,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final rnd = Random(item.id.hashCode);
    final double bottomStagger = 5.0 + rnd.nextInt(20); 

    return GestureDetector(
      onLongPress: () {
        searchFocusNode.unfocus();
        HapticService.medium();
        onSelect(item.id);
      },
      onTap: () {
        searchFocusNode.unfocus();
        if (isSelectionMode) {
          HapticService.light();
          onSelect(item.id);
        } else {
          HapticService.light();
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item, onDelete: onUpdate))
          );
        }
      },
      child: AnimatedScale(
        scale: isSelected ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 100),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              Opacity(
                opacity: isSelected ? 0.4 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                      Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.type == 'link')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                Uri.parse(item.content).host.replaceFirst('www.', '').toLowerCase(),
                                style: GoogleFonts.ibmPlexMono(
                                  color: Colors.white24, 
                                  fontSize: 9, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Text(
                            item.title.isEmpty ? "Untitled Fragment" : item.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.white, 
                              fontSize: 14, 
                              fontWeight: FontWeight.w600, 
                              height: 1.2
                            ),
                          ),
                          if (item.summary.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                item.summary,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexSans(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          // 🔥 REMOVED: AI Tags Display
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Row(
                        children: [
                          Icon(item.type == 'link' ? Icons.link : Icons.notes_rounded, size: 10, color: Colors.white10),
                          const SizedBox(width: 8),
                          Text(
                            "${item.createdAt.day}/${item.createdAt.month}",
                            style: GoogleFonts.ibmPlexMono(color: Colors.white10, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: bottomStagger),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}