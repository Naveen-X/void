// ui/home/item_detail_screen.dart
// Update this existing file
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/void_dialog.dart';

class ItemDetailScreen extends StatelessWidget {
  final VoidItem item;
  final VoidCallback onDelete;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    HapticService.warning();
    final bool? confirm = await VoidDialog.show(
      context: context,
      title: "ERASE FRAGMENT?",
      message: "This fragment will be permanently lost to the void.",
      confirmText: "ERASE",
      icon: Icons.delete_forever_rounded,
    );

    if (confirm == true) {
      HapticService.heavy();
      await VoidStore.delete(item.id);
      onDelete();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: item.imageUrl != null ? 320 : 100,
            backgroundColor: Colors.black,
            elevation: 0,
            pinned: true,
            // Inside ItemDetailScreen, update the SliverAppBar leading:
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                onPressed: () => _confirmDelete(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.3),
                      colorBlendMode: BlendMode.darken,
                    )
                  : null,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI TAGS Display - Re-added
                  if (item.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag.toUpperCase(),
                                  style: GoogleFonts.ibmPlexMono(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.createdAt.toString().substring(0, 16),
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white24,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    item.title,
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (item.type == 'link') ...[
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(item.content)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blueAccent.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link,
                              color: Colors.blueAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexMono(
                                  color: Colors.blueAccent,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (item.summary.isNotEmpty)
                      Text(
                        item.summary,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                  ] else ...[
                    Text(
                      item.content,
                      style: GoogleFonts.ibmPlexSans(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
