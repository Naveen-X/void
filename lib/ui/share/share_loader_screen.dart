import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/link_metadata_service.dart';
import 'package:void_space/services/share_bridge.dart';
import 'package:void_space/services/haptic_service.dart';
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

    final text = await ShareBridge.getSharedText();
    if (text == null || text.isEmpty) { _close(); return; }

    VoidItem item;
    try {
      item = await LinkMetadataService.fetch(text).timeout(const Duration(seconds: 5));
    } catch (_) {
      item = VoidItem.fallback(text);
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
        // 🔥 THE IMMERSIVE VIGNETTE (Tunnel Effect)
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.black.withValues(alpha: 0.7), // Center is clearer
              Colors.black.withValues(alpha: 1.0), // Edges are pitch black
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