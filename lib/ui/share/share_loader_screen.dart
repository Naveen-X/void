// ui/share/share_loader_screen.dart
// Update this existing file
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/link_metadata_service.dart';
import 'package:void_space/services/share_bridge.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/services/ai_service.dart'; // Import AI service
import 'orb_loader.dart';

class ShareLoaderScreen extends StatefulWidget {
  const ShareLoaderScreen({super.key});
  @override
  State<ShareLoaderScreen> createState() => _ShareLoaderScreenState();
}

class _ShareLoaderScreenState extends State<ShareLoaderScreen> {
  OrbState _orbState = OrbState.idle;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _processShare());
  }

  Future<void> _processShare() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _orbState = OrbState.processing);

    final rawText = await ShareBridge.getSharedText();
    if (rawText == null || rawText.isEmpty) {
      _close();
      return;
    }

    VoidItem item;
    AIContext aiContext;

    if (rawText.startsWith('http')) {
      try {
        item = await LinkMetadataService.fetch(rawText).timeout(const Duration(seconds: 5));
      } catch (_) {
        // If metadata fetch fails, fallback and then analyze
        item = VoidItem.fallback(rawText, type: 'link');
        aiContext = await AIService.analyze(item.title, item.summary);
        item = VoidItem(
          id: item.id, type: item.type, content: item.content,
          title: aiContext.title, summary: aiContext.tldr,
          imageUrl: item.imageUrl, createdAt: item.createdAt,
          tags: aiContext.tags, embedding: aiContext.embedding,
        );
      }
    } else {
      // It's a note
      aiContext = await AIService.analyze(rawText.split('\n').first, rawText);
      item = VoidItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'note',
        content: rawText,
        title: aiContext.title,
        summary: aiContext.tldr,
        imageUrl: null,
        createdAt: DateTime.now(),
        tags: aiContext.tags,
        embedding: aiContext.embedding,
      );
    }

    await VoidStore.add(item);
    HapticService.success();

    if (mounted) {
      setState(() {
        _orbState = OrbState.success;
        _showToast = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 2200));
    _close();
  }

  void _close() => ShareBridge.close();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.black.withValues(alpha: 0.92),
              Colors.black.withValues(alpha: 0.70),
            ],
            stops: const [0.2, 0.9],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OrbLoader(state: _orbState),
              const SizedBox(height: 40),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _showToast ? 1.0 : 0.0,
                curve: Curves.easeOut,
                child: _showToast ? _buildToast() : const SizedBox(height: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToast() {
    return Material(
      type: MaterialType.transparency,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutExpo,
        builder: (context, val, child) => Transform.translate(
          offset: Offset(0, 15 * (1 - val)),
          child: Opacity(opacity: val, child: child),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111111).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30)
            ]
          ),
          child: Text(
            "FRAGMENT SAVED",
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}