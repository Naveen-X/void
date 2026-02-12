
import 'package:flutter/foundation.dart';

import '../data/models/void_item.dart';
import 'embedding_service.dart';

/// Semantic search service using local ONNX embeddings + cosine similarity.
/// Falls back to keyword-based search when embeddings are unavailable.
class RagService {
  static bool _initialized = true; 
  static bool get isInitialized => _initialized;

  /// No-op initialization (EmbeddingService is initialized separately)
  static Future<void> init({Function(String)? onProgress}) async {
    _initialized = true;
  }

  /// Finds items similar to the given item using embedding cosine similarity.
  /// Falls back to keyword matching if embeddings are missing.
  static Future<List<String>> findSimilar(VoidItem item, List<VoidItem> allItems, {int limit = 5}) async {
    final scores = <String, double>{};

    // Try vector similarity first
    if (item.embedding != null && item.embedding!.isNotEmpty) {
      for (final other in allItems) {
        if (other.id == item.id) continue;
        if (other.embedding != null && other.embedding!.isNotEmpty) {
          final score = EmbeddingService.cosineSimilarity(item.embedding!, other.embedding!);
          if (score > 0.2) {
            scores[other.id] = score;
          }
        }
      }
    }

    // If we found enough results with embeddings, return them
    if (scores.length >= limit) {
      final sorted = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted.take(limit).map((e) => e.key).toList();
    }

    // Supplement with keyword fallback for items without embeddings
    for (final other in allItems) {
      if (other.id == item.id) continue;
      if (scores.containsKey(other.id)) continue;

      double score = 0;

      // Tag overlap
      final commonTags = item.tags.toSet().intersection(other.tags.toSet());
      score += commonTags.length * 5.0;

      // Type match
      if (item.type == other.type) score += 2.0;

      // Title word overlap
      final titleWords = item.title.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 2).toSet();
      final otherTitleWords = other.title.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 2).toSet();
      score += titleWords.intersection(otherTitleWords).length * 3.0;

      if (score > 0) {
        // Scale keyword scores to 0-1 range to mix with cosine scores
        scores[other.id] = score / 20.0;
      }
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// Search using cosine similarity between query embedding and item embeddings.
  /// Falls back to keyword search for items without embeddings.
  static Future<List<String>> search(String query, List<VoidItem> allItems, {int limit = 10}) async {
    if (query.trim().isEmpty || allItems.isEmpty) return [];

    final scores = <String, double>{};

    // Try embedding-based search
    if (EmbeddingService.isInitialized) {
      final queryEmbedding = await EmbeddingService.embed(query);
      if (queryEmbedding != null) {
        for (final item in allItems) {
          if (item.embedding != null && item.embedding!.isNotEmpty) {
            final score = EmbeddingService.cosineSimilarity(queryEmbedding, item.embedding!);
            if (score > 0.15) {
              scores[item.id] = score;
            }
          }
        }

        // If we got good embedding results, return them
        if (scores.isNotEmpty) {
          final sorted = scores.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return sorted.take(limit).map((e) => e.key).toList();
        }
      }
    }

    // Keyword fallback
    final lowerQuery = query.toLowerCase();
    final queryWords = lowerQuery.split(RegExp(r'\W+')).where((w) => w.length > 2).toList();

    for (final item in allItems) {
      double score = 0;

      // Exact title match
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

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  // Compatibility methods — no-ops
  static Future<void> addItem(VoidItem item) async {}
  static Future<void> addItems(List<VoidItem> items, {Function(int, int)? onProgress}) async {}
  static Future<void> removeItem(String id) async {}
  static Future<void> rebuildIndex() async {}
  static Future<void> clear() async {}
  static Future<void> loadSourceMappings() async {}
}
