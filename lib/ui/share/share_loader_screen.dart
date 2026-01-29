
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/link_metadata_service.dart';
import 'package:void_space/services/share_bridge.dart';
import 'orb_loader.dart';

class ShareLoaderScreen extends StatefulWidget {
  const ShareLoaderScreen({super.key});
  @override
  State<ShareLoaderScreen> createState() => _ShareLoaderScreenState();
}

class _ShareLoaderScreenState extends State<ShareLoaderScreen> {
  OrbState _orbState = OrbState.idle;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _processShare());
  }

  Future<void> _processShare() async {
    // 1. Initial breathing time
    await Future.delayed(const Duration(milliseconds: 600));

    // 2. Start Processing
    if (mounted) setState(() => _orbState = OrbState.processing);

    final text = await ShareBridge.getSharedText();
    if (text == null || text.isEmpty) {
      _close();
      return;
    }

    VoidItem item;
    try {
      item = await LinkMetadataService.fetch(text).timeout(const Duration(seconds: 4));
    } catch (_) {
      item = VoidItem.fallback(text);
    }

    try {
      await VoidStore.add(item);
    } catch (_) {}

    // 3. Success (Expansion)
    if (mounted) setState(() => _orbState = OrbState.success);

    // 4. Wait for expansion animation
    await Future.delayed(const Duration(milliseconds: 600));
    _close();
  }

  void _close() {
    ShareBridge.close();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 FIX: Remove Scaffold. Use Container with explicit alignment.
    return Directionality( // Required because we removed Scaffold/Material
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center, // <--- This forces the Orb to the center
        child: OrbLoader(state: _orbState),
      ),
    );
  }
}
