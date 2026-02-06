import 'rag_service.dart';

/// Context returned by AI analysis
class AIContext {
  final String title;
  final String tldr;
  final List<String> tags;
  final List<double>? embedding;
  
  AIContext({
    required this.title, 
    required this.tldr, 
    required this.tags, 
    this.embedding,
  });
}

/// Service for AI-powered analysis and tagging
class AIService {
  static Future<void> init() async {
    // RAG service initialization is handled separately in splash screen
  }

  /// Analyze content and generate tags + embedding
  static Future<AIContext> analyze(String rawTitle, String rawSummary) async {
    List<String> generatedTags = [];
    String combinedText = "$rawTitle $rawSummary".toLowerCase();

    // Keyword-based tagging (fallback/supplement)
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
    
    if (generatedTags.isEmpty) {
      generatedTags.add("General");
    }

    // Generate embedding if RAG service is available
    List<double>? embedding;
    if (RagService.isInitialized && combinedText.isNotEmpty) {
      try {
        embedding = await RagService.generateEmbedding(combinedText);
      } catch (e) {
        // Silently fail - embedding is optional
      }
    }

    return AIContext(
      title: rawTitle,
      tldr: rawSummary,
      tags: generatedTags.toSet().toList(),
      embedding: embedding,
    );
  }
}