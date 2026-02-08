// ui/home/manual_entry_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/void_item.dart';
import '../../data/stores/void_store.dart';
import '../../services/link_metadata_service.dart';
import '../../services/haptic_service.dart';
import '../../services/ai_service.dart';
import '../../ui/theme/void_theme.dart';

class ManualEntryOverlay extends StatefulWidget {
  final VoidCallback onSave;
  const ManualEntryOverlay({super.key, required this.onSave});

  @override
  State<ManualEntryOverlay> createState() => _ManualEntryOverlayState();
}

class _ManualEntryOverlayState extends State<ManualEntryOverlay> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    HapticService.light();
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _controller.text = data!.text!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  Future<void> _handleSave() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);
    HapticService.medium();

    try {
      // CloudflareAI doesn't need initialization
      VoidItem item;
      if (_isLink) {
        String url = text;
        if (!url.startsWith('http')) {
          url = 'https://$url';
        }
        try {
          item = await LinkMetadataService.fetch(url).timeout(const Duration(seconds: 20));
        } catch (_) {
          item = VoidItem.fallback(url, type: 'link');
        }
      } else {
        try {
          final aiContext = await AIService.analyze(
            text.split('\n').first,
            text,
          ).timeout(const Duration(seconds: 20));
          
          item = VoidItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'note',
            content: text,
            title: aiContext.title,
            summary: aiContext.summary,
            tldr: aiContext.tldr,
            imageUrl: null,
            createdAt: DateTime.now(),
            tags: aiContext.tags,
            embedding: aiContext.embedding,
          );
        } catch (_) {
          item = VoidItem.fallback(text, type: 'note');
        }
      }

      await VoidStore.add(item);
      HapticService.success();
      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Save failed: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save fragment. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  bool get _isLink {
    final text = _controller.text.trim();
    // Regex for detecting URLs with or without protocol
    final urlRegex = RegExp(
      r'^(https?:\/\/)?' // Protocol (optional)
      r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})' // Domain
      r'(:\d+)?(\/.*)?$', // Port and Path (optional)
      caseSensitive: false,
    );
    return urlRegex.hasMatch(text);
  }
  bool get _isVideo => _isLink && (_controller.text.contains('youtube.com') || _controller.text.contains('youtu.be'));
  bool get _isSocial => _isLink && (_controller.text.contains('instagram.com') || _controller.text.contains('twitter.com') || _controller.text.contains('x.com') || _controller.text.contains('threads.net'));
  bool get _hasContent => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isFocused = _focusNode.hasFocus;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.bgCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isFocused 
              ? theme.textPrimary.withValues(alpha: 0.15)
              : theme.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isProcessing 
                                ? Colors.orangeAccent.withValues(alpha: _pulseAnimation.value)
                                : (_isVideo ? Colors.purpleAccent : (_isSocial ? Colors.pinkAccent : (_isLink ? Colors.blueAccent : Colors.greenAccent))).withValues(alpha: 0.6),
                              boxShadow: _isProcessing ? [
                                BoxShadow(
                                  color: Colors.orangeAccent.withValues(alpha: _pulseAnimation.value * 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isProcessing 
                          ? "PROCESSING..." 
                          : (_isVideo ? "VIDEO DETECTED" : (_isSocial ? "SOCIAL DETECTED" : (_isLink ? "LINK DETECTED" : "NEW FRAGMENT"))),
                        style: GoogleFonts.ibmPlexMono(
                          color: _isProcessing 
                            ? Colors.orangeAccent 
                            : theme.textSecondary.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      if (_controller.text.isEmpty)
                        GestureDetector(
                          onTap: _pasteFromClipboard,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.content_paste_rounded, size: 12, color: Colors.blueAccent),
                                const SizedBox(width: 4),
                                Text(
                                  'Paste',
                                  style: GoogleFonts.ibmPlexMono(
                                    color: Colors.blueAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Input container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.textPrimary.withValues(alpha: isFocused ? 0.04 : 0.02),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isFocused 
                          ? (_isLink ? Colors.blueAccent : theme.textPrimary).withValues(alpha: 0.15)
                          : theme.textPrimary.withValues(alpha: 0.05),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLines: 5,
                      minLines: 1,
                      enabled: !_isProcessing,
                      style: GoogleFonts.ibmPlexMono(
                        color: theme.textPrimary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      cursorColor: _isLink ? Colors.blueAccent : theme.textPrimary,
                      decoration: InputDecoration(
                        hintText: "Paste a link or type a note...",
                        hintStyle: GoogleFonts.ibmPlexMono(
                          color: theme.textPrimary.withValues(alpha: 0.15),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _handleSave(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Character count and submit button
                  Row(
                    children: [
                      // Character count
                      if (_hasContent)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _hasContent ? 1.0 : 0.0,
                          child: Text(
                            '${_controller.text.length} chars',
                            style: GoogleFonts.ibmPlexMono(
                              color: theme.textSecondary.withValues(alpha: 0.3),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      
                      const Spacer(),

                      // Submit button
                      GestureDetector(
                        onTap: _hasContent && !_isProcessing ? _handleSave : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: _hasContent ? 100 : 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _hasContent 
                              ? (_isLink ? Colors.blueAccent : theme.textPrimary)
                              : theme.textPrimary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(_hasContent ? 24 : 24),
                            boxShadow: _hasContent ? [
                              BoxShadow(
                                color: (_isLink ? Colors.blueAccent : theme.textPrimary).withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: _isProcessing 
                            ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.bgCard,
                                  ),
                                ),
                              )
                            : Center(
                                child: _hasContent
                                  ? Text(
                                      'Save',
                                      style: GoogleFonts.ibmPlexMono(
                                        color: _isLink ? Colors.white : theme.bgCard,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                      color: theme.textPrimary.withValues(alpha: 0.24),
                                    ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
