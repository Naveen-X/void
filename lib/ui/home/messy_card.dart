import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/void_item.dart';
import '../../services/haptic_service.dart';
import 'item_detail_screen.dart';

class MessyCard extends StatelessWidget {
  final VoidItem item;
  final VoidCallback onUpdate;

  const MessyCard({super.key, required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item, onDelete: onUpdate))
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 🔥 Wrap content
          children: [
            // 1. IMAGE
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),

            // 2. TEXT CONTENT
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain/Source (New Detail)
                  if (item.type == 'link')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        Uri.parse(item.content).host.replaceFirst('www.', ''),
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white24,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  // Title
                  Text(
                    item.title.isEmpty ? "Untitled Fragment" : item.title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  
                  // Summary (Only if no image, to keep cards from getting TOO long)
                  if (item.summary.isNotEmpty && item.imageUrl == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        item.summary,
                        maxLines: 5,
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
            
            // 3. FOOTER
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
                  Flexible(
                    child: Text(
                      _formatDate(item.createdAt),
                      overflow: TextOverflow.ellipsis,
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
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month} • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}