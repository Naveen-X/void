// services/link_metadata_service.dart
// Update this existing file
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'package:void_space/app/feature_flags.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/services/ai_service.dart'; // Import AI service

class LinkMetadataService {
  static Future<VoidItem> fetch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return VoidItem.fallback(url);
    }

    try {
      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('Failed to load page: ${res.statusCode}');
      }

      String body;
      try {
        body = utf8.decode(res.bodyBytes);
      } catch (e) {
        // Fallback to latin1 if utf8 fails
        body = latin1.decode(res.bodyBytes);
      }

    final doc = html.parse(body);

    String? pickMeta(String key) {
      return doc
          .querySelector('meta[property="$key"]')
          ?.attributes['content'];
    }

    final title =
        pickMeta('og:title') ??
        doc.querySelector('title')?.text ??
        uri.host;

    final summary =
        pickMeta('og:description') ??
        pickMeta('description') ??
        '';

    final imageUrl = pickMeta('og:image');

    // Determine specific type based on domain
    String finalType = 'link';
    final host = uri.host.toLowerCase();
    
    if (host.contains('youtube.com') || host.contains('youtu.be') || host.contains('vimeo.com')) {
      finalType = 'video';
    } else if (host.contains('instagram.com') || 
               host.contains('twitter.com') || 
               host.contains('x.com') || 
               host.contains('threads.net')) {
      finalType = 'social';
    }

    // Use AI service to analyze and get tags/embedding
    final aiContext = await AIService.analyze(title.trim(), summary.trim(), url: url);

    return VoidItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: finalType,
      content: url,
      title: aiContext.title,
      summary: aiContext.summary, // The 3-5 sentence one
      tldr: aiContext.tldr,       // The crisp single sentence
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      tags: aiContext.tags,
      embedding: aiContext.embedding,
    );
  } catch (e) {
      // Even if scraping fails, try to get AI context from the URL itself
      if (isAiEnabled) {
        try {
          final aiContext = await AIService.analyze('', url, url: url);
          return VoidItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'link',
            content: url,
            title: aiContext.title.isNotEmpty ? aiContext.title : (Uri.tryParse(url)?.host ?? 'Saved Link'),
            summary: aiContext.summary,
            tldr: aiContext.tldr,
            imageUrl: null,
            createdAt: DateTime.now(),
            tags: aiContext.tags,
            embedding: aiContext.embedding,
          );
        } catch (_) {
          return VoidItem.fallback(url);
        }
      }
      return VoidItem.fallback(url);
    }
  }
}