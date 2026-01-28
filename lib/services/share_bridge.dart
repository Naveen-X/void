import 'package:flutter/services.dart';

class ShareBridge {
  static const MethodChannel _channel = MethodChannel('void/share');

  /// 1. Ask Native if there is text waiting (The Pull)
  static Future<String?> getSharedText() async {
    try {
      final String? text = await _channel.invokeMethod('getSharedText');
      return text;
    } on PlatformException catch (_) {
      return null;
    }
  }

  /// 2. Tell Native we are finished saving
  static Future<void> close() async {
    try {
      await _channel.invokeMethod('done');
    } catch (_) {}
  }
}