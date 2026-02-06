// ui/share/share_loader_screen.dart
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/link_metadata_service.dart';
import 'package:void_space/services/share_bridge.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/services/ai_service.dart';
import 'package:void_space/services/groq_service.dart';
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
    _initAndProcess();
  }
  
  Future<void> _initAndProcess() async {
    try {
      developer.log('ShareLoaderScreen: Starting init and process', name: 'ShareLoader');
      
      // Initialize Hive
      await VoidStore.init();
      
      // CRITICAL: Ensure AI Service is ready
      // The Share intent runs in a separate FlutterActivty/Isolate context on Android sometimes,
      // so static variables from the main app might not be present. We MUST reload the key.
      if (!GroqService.isConfigured) {
         developer.log('ShareLoaderScreen: GroqService not configured. Initializing...', name: 'ShareLoader');
         await GroqService.init();
      }
      
      // Verification
      if (GroqService.isConfigured) {
        developer.log('ShareLoaderScreen: GroqService READY. Key present.', name: 'ShareLoader');
      } else {
        developer.log('ShareLoaderScreen: WARNING: GroqService failed to load key. AI will be disabled.', name: 'ShareLoader');
      }
      
      await _processShare();
    } catch (e) {
      developer.log('ShareLoaderScreen: Error in _initAndProcess: $e', name: 'ShareLoader');
      _close();
    }
  }
  
  Future<void> _processShare() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _orbState = OrbState.processing);

    try {
      developer.log('ShareLoaderScreen: Checking for shared file', name: 'ShareLoader');
      
      // First check for file share
      final sharedFile = await ShareBridge.getSharedFile();
      developer.log('ShareLoaderScreen: sharedFile = $sharedFile', name: 'ShareLoader');
      
      if (sharedFile != null) {
        await _processFileShare(sharedFile);
        return;
      }

      developer.log('ShareLoaderScreen: Checking for shared text', name: 'ShareLoader');
      
      // Fall back to text share
      final rawText = await ShareBridge.getSharedText();
      developer.log('ShareLoaderScreen: rawText = $rawText', name: 'ShareLoader');
      
      if (rawText == null || rawText.isEmpty) {
        developer.log('ShareLoaderScreen: No shared content found, closing', name: 'ShareLoader');
        _close();
        return;
      }

      await _processTextShare(rawText);
    } catch (e) {
      developer.log('ShareLoaderScreen: Error in _processShare: $e', name: 'ShareLoader');
      _close();
    }
  }
  
  Future<void> _processTextShare(String rawText) async {
    try {
      developer.log('ShareLoaderScreen: Processing text share', name: 'ShareLoader');
      
      VoidItem item;

      if (rawText.startsWith('http')) {
        try {
          // DIRECT MATCH OF MANUAL ENTRY LOGIC:
          // We trust LinkMetadataService to do the heavy lifting (Scraping + AI).
          // It has its own internal AI calls and fallbacks.
          item = await LinkMetadataService.fetch(rawText).timeout(const Duration(seconds: 20));
        } catch (_) {
          // If the service itself crashes (timeout or network), we fallback to a basic link item
          item = VoidItem.fallback(rawText, type: 'link');
        }
      } else {
        // Text Note Logic (Direct Match to ManualEntryOverlay)
        try {
          final aiContext = await AIService.analyze(
            rawText.split('\n').first,
            rawText,
          ).timeout(const Duration(seconds: 20));
          
          item = VoidItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'note',
            content: rawText,
            title: aiContext.title,
            summary: aiContext.summary,
            tldr: aiContext.tldr,
            imageUrl: null,
            createdAt: DateTime.now(),
            tags: aiContext.tags,
            embedding: aiContext.embedding,
          );
        } catch (_) {
          item = VoidItem.fallback(rawText, type: 'note');
        }
      }

      developer.log('ShareLoaderScreen: Saving text item to store', name: 'ShareLoader');
      await VoidStore.add(item);
      HapticService.success();

      developer.log('ShareLoaderScreen: Text share complete, showing success', name: 'ShareLoader');
      if (mounted) {
        setState(() {
          _orbState = OrbState.success;
          _showToast = true;
        });
      }

      await Future.delayed(const Duration(milliseconds: 2200));
      _close();
    } catch (e) {
      developer.log('ShareLoaderScreen: Error processing text: $e', name: 'ShareLoader');
      _close();
    }
  }

  Future<void> _processFileShare(SharedFile sharedFile) async {
    try {
      developer.log('ShareLoaderScreen: Processing file: ${sharedFile.path}, mime: ${sharedFile.mimeType}', name: 'ShareLoader');
      
      final file = File(sharedFile.path);
      final exists = await file.exists();
      developer.log('ShareLoaderScreen: File exists: $exists', name: 'ShareLoader');
      
      if (!exists) {
        developer.log('ShareLoaderScreen: File does not exist, closing', name: 'ShareLoader');
        _close();
        return;
      }

      // Determine type based on MIME
      String itemType = 'file';
      if (sharedFile.mimeType?.startsWith('image/') == true) {
        itemType = 'image';
      } else if (sharedFile.mimeType?.startsWith('video/') == true) {
        itemType = 'video';
      } else if (sharedFile.mimeType == 'application/pdf') {
        itemType = 'pdf';
      } else if (sharedFile.mimeType?.startsWith('text/') == true) {
        itemType = 'document';
      }
      
      developer.log('ShareLoaderScreen: Determined item type: $itemType', name: 'ShareLoader');

      // Copy file to app documents directory for persistent access
      final appDir = await getApplicationDocumentsDirectory();
      final filename = file.path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final persistentPath = '${appDir.path}/$timestamp-$filename';
      final persistentFile = File(persistentPath);
      
      developer.log('ShareLoaderScreen: Copying to: $persistentPath', name: 'ShareLoader');
      await file.copy(persistentFile.path);

      // Delete cache file (ignore errors)
      try {
        await file.delete();
      } catch (e) {
        developer.log('ShareLoaderScreen: Could not delete cache file: $e', name: 'ShareLoader');
      }

      // Get file info for metadata
      final fileSize = await persistentFile.length();
      final sizeMB = (fileSize / 1024 / 1024).toStringAsFixed(2);

      // Create VoidItem with file info
      final item = VoidItem(
        id: timestamp.toString(),
        type: itemType,
        content: persistentFile.path,
        title: filename,
        summary: '${itemType.toUpperCase()} • ${sizeMB}MB',
        imageUrl: itemType == 'image' ? persistentFile.path : null,
        createdAt: DateTime.now(),
        tags: [itemType, 'shared'],
        embedding: null,
      );

      developer.log('ShareLoaderScreen: Saving item to store', name: 'ShareLoader');
      await VoidStore.add(item);
      HapticService.success();

      developer.log('ShareLoaderScreen: File share complete, showing success', name: 'ShareLoader');
      if (mounted) {
        setState(() {
          _orbState = OrbState.success;
          _showToast = true;
        });
      }

      await Future.delayed(const Duration(milliseconds: 2200));
      _close();
    } catch (e) {
      developer.log('ShareLoaderScreen: Error processing file: $e', name: 'ShareLoader');
      _close();
    }
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
