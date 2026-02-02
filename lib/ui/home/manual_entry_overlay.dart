// ui/home/manual_entry_overlay.dart
// Update this existing file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/void_item.dart';
import '../../data/stores/void_store.dart';
import '../../services/link_metadata_service.dart';
import '../../services/haptic_service.dart';
import '../../services/ai_service.dart'; // Import AI service

class ManualEntryOverlay extends StatefulWidget {
  final VoidCallback onSave;
  const ManualEntryOverlay({super.key, required this.onSave});

  @override
  State<ManualEntryOverlay> createState() => _ManualEntryOverlayState();
}

class _ManualEntryOverlayState extends State<ManualEntryOverlay> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkClipboard();
  }

  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text?.startsWith('http') ?? false) {
      // Optional: Show a "Paste Link" chip above the keyboard
    }
  }

  Future<void> _handleSave() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);
    HapticService.medium();

    VoidItem item;
    // Check if it's a link
    if (text.startsWith('http')) {
      try {
        item = await LinkMetadataService.fetch(
          text,
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        item = VoidItem.fallback(text, type: 'link');
      }
    } else {
      // It's a note
      final aiContext = await AIService.analyze(
        text.split('\n').first,
        text,
      ); // Analyze note content
      item = VoidItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'note',
        content: text,
        title: aiContext.title, // Use AI-analyzed title
        summary: aiContext.tldr, // Use AI-analyzed summary
        imageUrl: null,
        createdAt: DateTime.now(),
        tags: aiContext.tags, // Add generated tags
        embedding: aiContext.embedding, // Add generated embedding
      );
    }

    await VoidStore.add(item);
    HapticService.success();
    widget.onSave();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isProcessing
                  ? "// PROCESSING_FRAGMENT..."
                  : "// INPUT_NEW_FRAGMENT",
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white24,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 4,
              minLines: 1,
              style: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: "paste link or type note...",
                hintStyle: const TextStyle(color: Colors.white10),
                border: InputBorder.none,
                suffixIcon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.white24,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                        ),
                        onPressed: _handleSave,
                      ),
              ),
              onSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
