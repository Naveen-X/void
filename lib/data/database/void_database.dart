import 'package:hive_flutter/hive_flutter.dart';
import '../models/void_item.dart';

class VoidDatabase {
  static const String _boxName = 'void_items';
  static Box<VoidItem>? _box;

  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(VoidItemAdapter().typeId)) {
      Hive.registerAdapter(VoidItemAdapter());
    }
    
    _box = await Hive.openBox<VoidItem>(_boxName);
  }

  static Box<VoidItem> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _box!;
  }

  static Future<bool> isDuplicate(VoidItem newItem) async {
    final activeItems = box.values.where((item) => !item.isDeleted);
    
    for (final existingItem in activeItems) {
      if (existingItem.type != newItem.type) continue;
      
      // For links and notes, check if the exact trimmed text matches
      if (newItem.type == 'link' || newItem.type == 'note') {
        if (existingItem.content.trim() == newItem.content.trim()) {
          return true;
        }
      } 
      // For files/images, check the title (filename) and content (usually size representation)
      else if (newItem.type == 'file' || newItem.type == 'image' || newItem.type == 'video' || newItem.type == 'pdf' || newItem.type == 'document') {
         if (existingItem.title == newItem.title && existingItem.content == newItem.content) {
            return true;
         }
      }
    }
    
    return false;
  }

  static Future<void> insertItem(VoidItem item) async {
    await box.put(item.id, item);
  }

  static Future<List<VoidItem>> getAllItems({bool includeDeleted = false}) async {
    var items = box.values.toList();
    if (!includeDeleted) {
      items = items.where((item) => !item.isDeleted).toList();
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<List<VoidItem>> getDeletedItems() async {
    final items = box.values.where((item) => item.isDeleted).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> softDeleteItem(String id) async {
    final item = box.get(id);
    if (item != null) {
      await box.put(id, item.copyWith(isDeleted: true));
    }
  }

  static Future<void> softDeleteManyItems(Set<String> ids) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
        final item = box.get(id);
        if (item != null) {
          await box.put(id, item.copyWith(isDeleted: true));
        }
    }
  }

  static Future<void> restoreItem(String id) async {
    final item = box.get(id);
    if (item != null) {
      await box.put(id, item.copyWith(isDeleted: false));
    }
  }

  static Future<void> permanentlyDeleteItem(String id) async {
    await box.delete(id);
  }

  static Future<void> permanentlyDeleteManyItems(Set<String> ids) async {
    if (ids.isEmpty) return;
    await box.deleteAll(ids);
  }

  static Future<List<VoidItem>> searchItems(String query, {bool includeDeleted = false}) async {
    if (query.trim().isEmpty) return getAllItems(includeDeleted: includeDeleted);
    
    final queryLower = query.toLowerCase();
    final results = box.values.where((item) {
      if (!includeDeleted && item.isDeleted) return false;
      return item.title.toLowerCase().contains(queryLower) ||
             (item.summary?.toLowerCase().contains(queryLower) ?? false) ||
             item.content.toLowerCase().contains(queryLower) ||
             item.tags.any((tag) => tag.toLowerCase().contains(queryLower));
    }).toList();
    
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  static Future<void> updateItem(VoidItem item) async {
    await box.put(item.id, item);
  }

  static Future<void> clear() async {
    await box.clear();
  }

  /// Refresh the box by closing and reopening to see changes from other isolates/engines
  static Future<void> refresh() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
    await init();
  }
}
