import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatelessWidget {
  final VoidItem item;
  final VoidCallback onDelete;

  const ItemDetailScreen({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR with Image Background
          SliverAppBar(
            expandedHeight: item.imageUrl != null ? 300 : 80,
            backgroundColor: Colors.black,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrl != null 
                ? Image.network(
                    item.imageUrl!, 
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.3), // Darken image
                    colorBlendMode: BlendMode.darken,
                  ) 
                : null,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                onPressed: () async {
                  await VoidStore.delete(item.id);
                  onDelete(); 
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),

          // 2. CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.createdAt.toString().substring(0, 16),
                        style: GoogleFonts.ibmPlexMono(color: Colors.white24, fontSize: 11),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    item.title,
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content / Link
                  if (item.type == 'link') ...[
                    // The Link Itself
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(item.content)),
                      child: Text(
                        item.content,
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Summary Block
                    if (item.summary.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.white24, width: 2)),
                        ),
                        child: Text(
                          item.summary,
                          style: GoogleFonts.ibmPlexSans(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),
                  ] else ...[
                    // Just Note Content
                    Text(
                      item.content,
                      style: GoogleFonts.ibmPlexSans(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}