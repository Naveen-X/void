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
  @override
  void initState() {
    super.initState();
    // Start logic after first frame render
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _processShare();
    });
  }

  Future<void> _processShare() async {
    // 1. Wait a moment for the animation to be visible (UX)
    await Future.delayed(const Duration(milliseconds: 600));

    // 2. PULL: Ask Native for the text
    final text = await ShareBridge.getSharedText();

    if (text == null || text.isEmpty) {
      _close();
      return;
    }

    // 3. Metadata Fetch
    VoidItem item;
    try {
      item = await LinkMetadataService.fetch(text)
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      item = VoidItem.fallback(text);
    }

    // 4. Save to Disk
    try {
      await VoidStore.add(item);
    } catch (e) {
      debugPrint("Save failed: $e");
    }

    // 5. Success Delay (let user see the orb pulse)
    await Future.delayed(const Duration(milliseconds: 400));
    
    _close();
  }

  void _close() {
    // 6. Tell Native to kill the activity
    ShareBridge.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: OrbLoader(),
      ),
    );
  }
}