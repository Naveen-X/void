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

  static Future<void> insertItem(VoidItem item) async {
    await box.put(item.id, item);
  }

  static Future<List<VoidItem>> getAllItems() async {
    final items = box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  static Future<void> deleteManyItems(Set<String> ids) async {
    if (ids.isEmpty) return;
    await box.deleteAll(ids);
  }

  static Future<List<VoidItem>> searchItems(String query) async {
    if (query.trim().isEmpty) return getAllItems();
    
    final queryLower = query.toLowerCase();
    final results = box.values.where((item) {
      return item.title.toLowerCase().contains(queryLower) ||
             item.summary.toLowerCase().contains(queryLower) ||
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
