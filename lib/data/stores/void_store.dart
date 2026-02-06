import '../database/void_database.dart';
import '../models/void_item.dart';
import '../../services/rag_service.dart';

class VoidStore {
  static Future<void> init() async {
    await VoidDatabase.init();
  }

  static Future<List<VoidItem>> all() async {
    return await VoidDatabase.getAllItems();
  }

  static Future<void> add(VoidItem item) async {
    await VoidDatabase.insertItem(item);
  }

  static Future<void> delete(String id) async {
    await VoidDatabase.deleteItem(id);
  }

  static Future<void> deleteMany(Set<String> ids) async {
    await VoidDatabase.deleteManyItems(ids);
  }

  static Future<List<VoidItem>> search(String query) async {
    return await VoidDatabase.searchItems(query);
  }

  /// Optimized search using lightweight similarity engine
  static Future<List<VoidItem>> semanticSearch(String query) async {
    final allItems = await all();
    final ids = await RagService.search(query, allItems);
    
    if (ids.isEmpty) return [];
    
    final itemMap = {for (var item in allItems) item.id: item};
    
    return ids
        .where((id) => itemMap.containsKey(id))
        .map((id) => itemMap[id]!)
        .toList();
  }

  /// Find items similar to the given item
  static Future<List<VoidItem>> findSimilar(VoidItem item, {int limit = 5}) async {
    final allItems = await all();
    final ids = await RagService.findSimilar(item, allItems, limit: limit);
    
    if (ids.isEmpty) return [];
    
    final itemMap = {for (var i in allItems) i.id: i};
    
    return ids
        .where((id) => itemMap.containsKey(id))
        .map((id) => itemMap[id]!)
        .toList();
  }

  static Future<void> update(VoidItem item) async {
    await VoidDatabase.updateItem(item);
  }

  /// Refresh the database to see changes from other isolates/engines
  static Future<void> refresh() async {
    await VoidDatabase.refresh();
  }

  /// Optimized rebuild (no-op since it is instant now)
  static Future<void> rebuildRagIndex({Function(int, int)? onProgress}) async {
    // No-op
  }
}