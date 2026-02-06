
import '../data/models/void_item.dart';

/// Lightweight service for keyword-based similarity and search.
/// Replaces the heavy ONNX-based RAG engine.
class RagService {
  // We keep the name RagService and these flags to maintain compatibility with existing code
  static bool _initialized = true; 
  static bool get isInitialized => _initialized;

  /// No-op initialization (always ready now)
  static Future<void> init({Function(String)? onProgress}) async {
    _initialized = true;
  }

  /// Finds items conceptually similar to the given item using weighted keyword matching.
  static Future<List<String>> findSimilar(VoidItem item, List<VoidItem> allItems, {int limit = 5}) async {
    final scores = <String, double>{};

    for (final other in allItems) {
      if (other.id == item.id) continue;

      double score = 0;

      // 1. Tag overlap (High Weight)
      final commonTags = item.tags.toSet().intersection(other.tags.toSet());
      score += commonTags.length * 5.0;

      // 2. Type match (Medium Weight)
      if (item.type == other.type) {
        score += 2.0;
      }

      // 3. Title word overlap (Medium Weight)
      final titleWords = item.title.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 2).toSet();
      final otherTitleWords = other.title.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 2).toSet();
      final commonTitleWords = titleWords.intersection(otherTitleWords);
      score += commonTitleWords.length * 3.0;

      // 4. Summary/Content overlap (Low Weight)
      final otherCombined = "${other.summary ?? ''} ${other.content}".toLowerCase();
      
      // Simple word check for significant overlaps
      for (final word in titleWords) {
        if (otherCombined.contains(word)) score += 0.5;
      }

      if (score > 0) {
        scores[other.id] = score;
      }
    }

    // Sort by score and take limit
    final sortedIds = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds.take(limit).map((e) => e.key).toList();
  }

  /// Semantic search fallback (now just re-uses optimized keyword search logic)
  static Future<List<String>> search(String query, List<VoidItem> allItems, {int limit = 10}) async {
    final lowerQuery = query.toLowerCase();
    final queryWords = lowerQuery.split(RegExp(r'\W+')).where((w) => w.length > 2).toList();
    
    final scores = <String, double>{};

    for (final item in allItems) {
      double score = 0;

      // Exact title match (Highest)
      if (item.title.toLowerCase() == lowerQuery) {
        score += 50.0;
      } else if (item.title.toLowerCase().contains(lowerQuery)) {
        score += 10.0;
      }

      // Tag match
      for (final tag in item.tags) {
        if (tag.toLowerCase() == lowerQuery) {
          score += 20.0;
        } else if (tag.toLowerCase().contains(lowerQuery)) {
          score += 5.0;
        }
      }

      // Word matches
      for (final word in queryWords) {
        if (item.title.toLowerCase().contains(word)) score += 5.0;
        if (item.summary?.toLowerCase().contains(word) ?? false) score += 2.0;
        if (item.content.toLowerCase().contains(word)) score += 1.0;
      }

      if (score > 0) {
        scores[item.id] = score;
      }
    }

    final sortedIds = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds.take(limit).map((e) => e.key).toList();
  }

  // Compatibility methods - now no-ops
  static Future<void> addItem(VoidItem item) async {}
  static Future<void> addItems(List<VoidItem> items, {Function(int, int)? onProgress}) async {}
  static Future<void> removeItem(String id) async {}
  static Future<void> rebuildIndex() async {}
  static Future<void> clear() async {}
  static Future<void> loadSourceMappings() async {}
}
