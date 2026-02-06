import 'groq_service.dart';

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
class AIService {
  static Future<void> init() async {
    await GroqService.init();
  }

  /// Analyze content and generate tags + summary. Optional [url] helps Gemini for links.
  static Future<AIContext> analyze(String rawTitle, String rawContent, {String? url}) async {
    String summary = '';
    String tldr = '';
    List<String> generatedTags = [];
    
    // Try Groq first if configured
    if (GroqService.isConfigured) {
      // User requested to provide link as input if available
      final result = await GroqService.analyze(rawTitle, rawContent, url: url);
      if (result != null) {
        summary = result.summary;
        tldr = result.tldr;
        generatedTags = result.tags;
      }
    }
    
    // Fallback to keyword-based tagging if Groq not available or failed
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
    // Fallback logic for summary and tldr
    if (summary.isEmpty) {
      // Use original content (which might be the URL or OG description)
      summary = rawContent;
    }
    if (tldr.isEmpty) {
      tldr = rawTitle.isNotEmpty ? rawTitle : "Saved Fragment";
    }

    return AIContext(
      title: rawTitle,
      summary: summary,
      tldr: tldr,
      tags: generatedTags.toSet().toList(),
      embedding: null, // Embeddings managed by RagService
    );
  }
}