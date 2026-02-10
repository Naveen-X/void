import 'package:void_space/app/feature_flags.dart';
import 'cloudflare_ai_service.dart';

/// Context returned by AI analysis
class AIContext {
  final String title;
  final String summary; // The 3-5 sentence one
  final String tldr;    // The single sentence one
  final List<String> tags;
  final List<double>? embedding;
  
  AIContext({
    required this.title, 
    required this.summary,
    required this.tldr, 
    required this.tags, 
    this.embedding,
  });
}

/// Service for AI-powered analysis and tagging
/// Uses Cloudflare Workers AI (Llama 3.2)
class AIService {
  static Future<void> init() async {
    // No initialization needed for Cloudflare AI
  }

  /// Analyze content and generate tags + summary. Optional [url] helps for links. Optional [imagePath] for images.
  static Future<AIContext> analyze(String rawTitle, String rawContent, {String? url, String? imagePath}) async {
    String title = rawTitle;
    String summary = '';
    String tldr = '';
    List<String> generatedTags = [];
    
    // Only call Cloudflare AI when the feature is enabled
    if (isAiEnabled) {
      final result = imagePath != null && imagePath.isNotEmpty
          ? await CloudflareAIService.analyzeImage(imagePath)
          : await CloudflareAIService.analyzeText(rawTitle, rawContent, url: url);
          
      if (result != null) {
        if (result.title.isNotEmpty) title = result.title;
        summary = result.summary;
        tldr = result.tldr;
        generatedTags = result.tags;
      }
    }
    
    // Fallback to keyword-based tagging if AI failed or disabled
    if (generatedTags.isEmpty) {
      String combinedText = "$rawTitle $rawContent ${url ?? ''}".toLowerCase();
      
      if (combinedText.contains("design") || combinedText.contains("ui") || combinedText.contains("figma")) {
        generatedTags.add("Design");
      }
      if (combinedText.contains("code") || combinedText.contains("tech") || combinedText.contains("programming") || 
          combinedText.contains("flutter") || combinedText.contains("dart") || combinedText.contains("github")) {
        generatedTags.add("Tech");
      }
      if (combinedText.contains("game") || combinedText.contains("gaming") || combinedText.contains("esports")) {
        generatedTags.add("Gaming");
      }
      if (combinedText.contains("tutorial") || combinedText.contains("how to") || combinedText.contains("guide")) {
        generatedTags.add("Tutorial");
      }
      if (combinedText.contains("video") || combinedText.contains("youtube") || combinedText.contains("watch")) {
        generatedTags.add("Video");
      }
      if (combinedText.contains("news") || combinedText.contains("article") || combinedText.contains("blog")) {
        generatedTags.add("Article");
      }
      if (combinedText.contains("tool") || combinedText.contains("app") || combinedText.contains("software")) {
        generatedTags.add("Tool");
      }
      if (combinedText.contains("ai") || combinedText.contains("machine learning") || combinedText.contains("ml") || 
          combinedText.contains("gpt") || combinedText.contains("llm")) {
        generatedTags.add("AI");
      }
      if (combinedText.contains("phone") || combinedText.contains("mobile") || combinedText.contains("oneplus") ||
          combinedText.contains("samsung") || combinedText.contains("iphone") || combinedText.contains("android")) {
        generatedTags.add("Mobile");
      }
      if (combinedText.contains("music") || combinedText.contains("song") || combinedText.contains("spotify")) {
        generatedTags.add("Music");
      }
      
      if (generatedTags.isEmpty) {
        generatedTags.add("General");
      }
    }

    // Fallback logic for summary and tldr
    if (summary.isEmpty) {
      summary = rawContent;
    }
    if (tldr.isEmpty) {
      tldr = rawTitle.isNotEmpty ? rawTitle : "Saved Fragment";
    }

    return AIContext(
      title: title,
      summary: summary,
      tldr: tldr,
      tags: generatedTags.toSet().toList(),
      embedding: null,
    );
  }
}