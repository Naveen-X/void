// lib/services/ai_service.dart

class AIContext {
  final String title;
  final String tldr;
  final List<String> tags;
  AIContext({required this.title, required this.tldr, required this.tags});
}

class AIService {
  // We don't need a heavy LLM engine for this basic tagging.
  // The 'embedding_service' will handle the actual embedding.
  static Future<void> init() async {
    // No specific initialization for this simple tagger.
    // It's mostly a placeholder for when we do integrate a cloud LLM or a small local LLM.
  }

  static Future<AIContext> analyze(String rawTitle, String rawSummary) async {
    // For now, simple keyword-based tagging and using original title/summary.
    List<String> generatedTags = [];
    String combinedText = "$rawTitle $rawSummary".toLowerCase();

    if (combinedText.contains("design") || combinedText.contains("ui") || combinedText.contains("figma")) {
      generatedTags.add("Design");
    }
    if (combinedText.contains("code") || combinedText.contains("tech") || combinedText.contains("programming")) {
      generatedTags.add("Tech");
    }
    if (combinedText.contains("game") || combinedText.contains("gaming") || combinedText.contains("esports")) {
      generatedTags.add("Gaming");
    }
    if (combinedText.contains("tutorial") || combinedText.contains("how to")) {
      generatedTags.add("Tutorial");
    }
    if (generatedTags.isEmpty) {
      generatedTags.add("General");
    }

    return AIContext(
      title: rawTitle,    // Keep original title
      tldr: rawSummary,   // Keep original summary (this is what's displayed as summary)
      tags: generatedTags.toSet().toList(), // Ensure unique tags
    );
  }
}