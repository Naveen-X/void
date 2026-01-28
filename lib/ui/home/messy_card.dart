import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/void_item.dart';
import 'item_detail_screen.dart';

class MessyCard extends StatelessWidget {
  final VoidItem item;
  final VoidCallback onUpdate;

  const MessyCard({super.key, required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final rnd = Random(item.id.hashCode);
    final offset = rnd.nextDouble() * 16 - 8; 

    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item, onDelete: onUpdate))
      ),
      child: Transform.translate(
        offset: Offset(0, offset),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMAGE
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.white10),
                    ),
                  ),
                ),

              // 2. CONTENT
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.isEmpty ? "Untitled Fragment" : item.title,
                        maxLines: item.imageUrl != null ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (item.summary.isNotEmpty)
                        Expanded(
                          child: Text(
                            item.summary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.white54,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // 3. FOOTER (🔥 FIX: Added Flexible to prevent overflow)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    Icon(
                      item.type == 'link' ? Icons.link : Icons.notes,
                      size: 10, 
                      color: Colors.white24
                    ),
                    const SizedBox(width: 6),
                    // Wrap text in Flexible to allow shrinking
                    Flexible(
                      child: Text(
                        _formatDate(item.createdAt),
                        overflow: TextOverflow.ellipsis, // Cut off if too narrow
                        maxLines: 1,
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white24,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}