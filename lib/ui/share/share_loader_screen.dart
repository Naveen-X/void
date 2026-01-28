import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Needed for post-frame callback

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
  @override
  void initState() {
    super.initState();
    // Run after build to ensure animation starts smoothly
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _processShare();
    });
  }

  Future<void> _processShare() async {
    // 1. Minimum animation time (UX)
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. PULL: Ask Native for the text
    final text = await ShareBridge.getSharedText();

    if (text == null || text.isEmpty) {
      _close();
      return;
    }

    // 3. Metadata Fetch & Save
    VoidItem item;
    try {
      item = await LinkMetadataService.fetch(text)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      item = VoidItem.fallback(text);
    }

    try {
      await VoidStore.add(item);
    } catch (e) {
      debugPrint("Save failed: $e");
    }

    // 4. Success Animation delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    _close();
  }

  void _close() {
    // 5. Tell Native to kill the activity via MethodChannel
    ShareBridge.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Opaque black to hide transparent activity quirks
      body: const Center(
        child: OrbLoader(),
      ),
    );
  }
}