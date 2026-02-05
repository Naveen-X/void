import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class SharedFile {
  final String path;
  final String? mimeType;
  final String? uri;

  SharedFile({required this.path, this.mimeType, this.uri});

  factory SharedFile.fromMap(Map<String, dynamic> map) {
    return SharedFile(
      path: map['path'] as String,
      mimeType: map['mimeType'] as String?,
      uri: map['uri'] as String?,
    );
  }

  @override
  String toString() => 'SharedFile(path: $path, mimeType: $mimeType, uri: $uri)';
}

class ShareBridge {
  static const MethodChannel _channel = MethodChannel('void/share');

  static Future<String?> getSharedText() async {
    try {
      final String? text = await _channel.invokeMethod('getSharedText');
      developer.log('ShareBridge.getSharedText: $text', name: 'ShareBridge');
      return text;
    } on PlatformException catch (e) {
      developer.log('ShareBridge.getSharedText error: $e', name: 'ShareBridge');
      return null;
    }
  }

  static Future<SharedFile?> getSharedFile() async {
    try {
      // Use dynamic return type to handle platform map conversion properly
      final dynamic result = await _channel.invokeMethod('getSharedFile');
      developer.log('ShareBridge.getSharedFile raw result: $result (${result.runtimeType})', name: 'ShareBridge');
      
      if (result == null) return null;
      
      // Convert platform map to Map<String, dynamic>
      if (result is Map) {
        final Map<String, dynamic> map = {};
        for (final entry in result.entries) {
          if (entry.key is String) {
            map[entry.key as String] = entry.value;
          }
        }
        
        // Validate required field
        if (!map.containsKey('path') || map['path'] == null) {
          developer.log('ShareBridge.getSharedFile: missing path field', name: 'ShareBridge');
          return null;
        }
        
        developer.log('ShareBridge.getSharedFile parsed: $map', name: 'ShareBridge');
        return SharedFile.fromMap(map);
      }
      
      developer.log('ShareBridge.getSharedFile: unexpected type ${result.runtimeType}', name: 'ShareBridge');
      return null;
    } on PlatformException catch (e) {
      developer.log('ShareBridge.getSharedFile error: $e', name: 'ShareBridge');
      return null;
    } catch (e) {
      developer.log('ShareBridge.getSharedFile unexpected error: $e', name: 'ShareBridge');
      return null;
    }
  }

  static Future<void> close() async {
    try {
      await _channel.invokeMethod('done');
    } catch (_) {}
  }
}
