import 'package:flutter/foundation.dart';

import '../database/void_database.dart';
import '../models/void_item.dart';
import '../../services/embedding_service.dart';
import '../../services/rag_service.dart';

class VoidStore {
  static Future<void> init() async {
    await VoidDatabase.init();
  }

  static Future<List<VoidItem>> all() async {
    return await VoidDatabase.getAllItems();
  }

  static Future<void> add(VoidItem item) async {
    // Generate embedding if service is ready and item doesn't have one
    final itemToStore = await _ensureEmbedding(item);
    await VoidDatabase.insertItem(itemToStore);
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

  /// Optimized search using cosine similarity on local embeddings
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
    // Re-generate embedding if content changed
    final itemToStore = await _ensureEmbedding(item);
    await VoidDatabase.updateItem(itemToStore);
  }

  /// Refresh the database to see changes from other isolates/engines
  static Future<void> refresh() async {
    await VoidDatabase.refresh();
  }

  /// Rebuild embeddings for all items that don't have them.
  /// Call this on first migration or when model changes.
  static Future<void> rebuildRagIndex({Function(int, int)? onProgress}) async {
    if (!EmbeddingService.isInitialized) {
      debugPrint('VoidStore: EmbeddingService not initialized, skipping rebuild');
      return;
    }

    final allItems = await all();
    final itemsNeedingEmbedding = allItems.where(
      (item) => item.embedding == null || item.embedding!.isEmpty,
    ).toList();

    if (itemsNeedingEmbedding.isEmpty) {
      debugPrint('VoidStore: All items already have embeddings');
      return;
    }

    debugPrint('VoidStore: Rebuilding embeddings for ${itemsNeedingEmbedding.length} items');

    for (int i = 0; i < itemsNeedingEmbedding.length; i++) {
      final item = itemsNeedingEmbedding[i];
      final text = _buildEmbeddingText(item);
      final embedding = await EmbeddingService.embed(text);

      if (embedding != null) {
        final updated = item.copyWith(embedding: embedding);
        await VoidDatabase.updateItem(updated);
      }

      onProgress?.call(i + 1, itemsNeedingEmbedding.length);
    }

    debugPrint('VoidStore: Embedding rebuild complete');
  }

  /// Ensure an item has an embedding before storage
  static Future<VoidItem> _ensureEmbedding(VoidItem item) async {
    if (!EmbeddingService.isInitialized) return item;
    if (item.embedding != null && item.embedding!.isNotEmpty) return item;

    final text = _buildEmbeddingText(item);
    final embedding = await EmbeddingService.embed(text);

    if (embedding != null) {
      return item.copyWith(embedding: embedding);
    }
    return item;
  }

  /// Build the text to embed from item fields
  static String _buildEmbeddingText(VoidItem item) {
    final parts = <String>[];
    if (item.title.isNotEmpty) parts.add(item.title);
    if (item.tldr != null && item.tldr!.isNotEmpty) parts.add(item.tldr!);
    if (item.summary != null && item.summary!.isNotEmpty) parts.add(item.summary!);
    // Add content snippet if short enough
    if (item.content.isNotEmpty && item.content.length <= 500) {
      parts.add(item.content);
    } else if (item.content.isNotEmpty) {
      parts.add(item.content.substring(0, 500));
    }
    return parts.join('. ');
  }
}