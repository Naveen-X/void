import 'package:mobile_rag_engine/mobile_rag_engine.dart';
import '../data/models/void_item.dart';

/// Service for RAG-based semantic search and embedding generation
class RagService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initialize the RAG engine with the model
  static Future<void> init({Function(double)? onProgress}) async {
    if (_initialized) return;

    try {
      await MobileRag.initialize(
        tokenizerAsset: 'assets/models/tokenizer.json',
        modelAsset: 'assets/models/model.onnx',
        threadLevel: ThreadUseLevel.medium,
        databaseName: 'void_rag.sqlite',
        maxChunkChars: 500,
        overlapChars: 50,
        onProgress: onProgress,
      );
      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  /// Generate embedding for text
  static Future<List<double>> generateEmbedding(String text) async {
    if (!_initialized) {
      throw StateError('RagService not initialized. Call init() first.');
    }
    
    // Use the embedding service to generate embeddings
    final embedding = await MobileRag.instance.getEmbedding(text);
    return embedding;
  }

  /// Add an item to the vector index
  static Future<void> addItem(VoidItem item) async {
    if (!_initialized) return;
    
    // Combine relevant text for the document
    final text = _buildSearchableText(item);
    if (text.isEmpty) return;

    await MobileRag.instance.addDocument(
      text,
      sourceId: item.id,
    );
  }

  /// Add multiple items (batch)
  static Future<void> addItems(List<VoidItem> items, {Function(int, int)? onProgress}) async {
    if (!_initialized) return;
    
    for (int i = 0; i < items.length; i++) {
      await addItem(items[i]);
      onProgress?.call(i + 1, items.length);
    }
  }

  /// Remove an item from the vector index
  static Future<void> removeItem(String id) async {
    if (!_initialized) return;
    await MobileRag.instance.deleteSource(id);
  }

  /// Rebuild the HNSW index after adding/removing items
  static Future<void> rebuildIndex() async {
    if (!_initialized) return;
    await MobileRag.instance.rebuildIndex();
  }

  /// Semantic search across all items
  static Future<List<String>> search(String query, {int limit = 10}) async {
    if (!_initialized) {
      return [];
    }
    
    final result = await MobileRag.instance.search(
      query,
      tokenBudget: 2000,
      topK: limit,
    );

    // Extract source IDs from results
    final sourceIds = <String>[];
    for (final chunk in result.chunks) {
      if (chunk.sourceId != null && !sourceIds.contains(chunk.sourceId)) {
        sourceIds.add(chunk.sourceId!);
      }
    }
    return sourceIds;
  }

  /// Find similar items to a given item
  static Future<List<String>> findSimilar(VoidItem item, {int limit = 5}) async {
    final text = _buildSearchableText(item);
    if (text.isEmpty) return [];
    
    final results = await search(text, limit: limit + 1);
    // Remove the item itself from results
    return results.where((id) => id != item.id).take(limit).toList();
  }

  /// Build searchable text from an item
  static String _buildSearchableText(VoidItem item) {
    final parts = <String>[];
    
    if (item.title.isNotEmpty) {
      parts.add(item.title);
    }
    if (item.summary.isNotEmpty) {
      parts.add(item.summary);
    }
    if (item.content.isNotEmpty && item.type == 'note') {
      parts.add(item.content);
    }
    if (item.tags.isNotEmpty) {
      parts.add(item.tags.join(' '));
    }
    
    return parts.join('\n');
  }

  /// Clear all data from the RAG index
  static Future<void> clear() async {
    if (!_initialized) return;
    await MobileRag.instance.clearAll();
  }
}
