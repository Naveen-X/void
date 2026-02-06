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
    // Add to RAG index for semantic search
    if (RagService.isInitialized) {
      await RagService.addItem(item);
    }
  }

  static Future<void> delete(String id) async {
    await VoidDatabase.deleteItem(id);
    // Remove from RAG index
    if (RagService.isInitialized) {
      await RagService.removeItem(id);
    }
  }

  static Future<void> deleteMany(Set<String> ids) async {
    await VoidDatabase.deleteManyItems(ids);
    // Remove from RAG index
    if (RagService.isInitialized) {
      for (final id in ids) {
        await RagService.removeItem(id);
      }
    }
  }

  static Future<List<VoidItem>> search(String query) async {
    return await VoidDatabase.searchItems(query);
  }

  /// Semantic search using embeddings
  static Future<List<VoidItem>> semanticSearch(String query) async {
    if (!RagService.isInitialized) {
      // Fallback to regular search
      return await search(query);
    }
    
    final ids = await RagService.search(query);
    if (ids.isEmpty) return [];
    
    final allItems = await all();
    final itemMap = {for (var item in allItems) item.id: item};
    
    return ids
        .where((id) => itemMap.containsKey(id))
        .map((id) => itemMap[id]!)
        .toList();
  }

  /// Find items similar to the given item
  static Future<List<VoidItem>> findSimilar(VoidItem item, {int limit = 5}) async {
    if (!RagService.isInitialized) return [];
    
    final ids = await RagService.findSimilar(item, limit: limit);
    if (ids.isEmpty) return [];
    
    final allItems = await all();
    final itemMap = {for (var i in allItems) i.id: i};
    
    return ids
        .where((id) => itemMap.containsKey(id))
        .map((id) => itemMap[id]!)
        .toList();
  }

  static Future<void> update(VoidItem item) async {
    await VoidDatabase.updateItem(item);
    // Update in RAG index
    if (RagService.isInitialized) {
      await RagService.removeItem(item.id);
      await RagService.addItem(item);
    }
  }

  /// Refresh the database to see changes from other isolates/engines
  static Future<void> refresh() async {
    await VoidDatabase.refresh();
  }

  /// Rebuild RAG index from all items
  static Future<void> rebuildRagIndex({Function(int, int)? onProgress}) async {
    if (!RagService.isInitialized) return;
    
    await RagService.clear();
    final items = await all();
    await RagService.addItems(items, onProgress: onProgress);
    await RagService.rebuildIndex();
  }
}