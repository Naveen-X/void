import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Result from Groq AI analysis
class GroqAnalysisResult {
  final String summary;
  final String tldr;
  final List<String> tags;
  
  GroqAnalysisResult({
    required this.summary, 
    required this.tldr, 
    required this.tags,
  });
}

/// Service for Groq AI integration (Llama 3)
class GroqService {
  static const String _apiKeyPref = 'groq_api_key';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant'; // Fast, reliable, free tier
  
  static String? _apiKey;
  
  static bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
  
  /// Load API key from storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPref);
  }
  
  /// Set and save API key
  static Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_apiKey!.isEmpty) {
      await prefs.remove(_apiKeyPref);
    } else {
      await prefs.setString(_apiKeyPref, _apiKey!);
    }
  }
  
  /// Get current API key
  static String? getApiKey() => _apiKey;
  
  /// Clear API key
  static Future<void> clearApiKey() async {
    _apiKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
  }
  
  /// Analyze content and generate summary + tags. Optionally takes a URL for context.
  static Future<GroqAnalysisResult?> analyze(String title, String content, {String? url}) async {
    if (_apiKey == null || _apiKey!.isEmpty) return null;
    
    try {
      final prompt = '''
You are a Digital Archivist. Your goal is to provide a realistic, observant, and aesthetic summary for saved content.

Context:
Title: $title
${url != null ? 'Source URL: $url' : ''}
Content Snippet: ${content.length > 2000 ? content.substring(0, 2000) : content.isEmpty ? "No content snippet available. Infer context from URL and Title." : content}

CRITICAL INSTRUCTIONS:
- ABSOLUTELY NO AI-SPEAK ("Discover", "Unlock", "Master").
- ABSOLUTELY NO FIRST PERSON ("I", "Me", "My"). Write as an objective, observant narrator.
- Tone: Clinical but aesthetic, like a museum plaque or a design magazine caption.
- Focus on the *essence* of the thing. What is it? What matches the vibe?
- If content is sparse, describe the site's purpose based on the URL.

OUTPUT FORMAT:
Return a valid JSON object with the following structure:
{
  "summary": "A detailed 3–5 sentence paragraph...",
  "tldr": "A single, minimalist, mymind-style sentence...",
  "tags": ["Tag1", "Tag2"]
}
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant that outputs only valid JSON.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'response_format': {'type': 'json_object'}, // Enforce JSON
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Groq API Error: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final choice = data['choices'][0];
      final contentStr = choice['message']['content'] as String;
      
      debugPrint('Groq Raw Response: $contentStr');
      
      final json = jsonDecode(contentStr);
      final summary = json['summary'] as String? ?? '';
      final tldr = json['tldr'] as String? ?? '';
      final tags = (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
      
      if (summary.isEmpty && tldr.isEmpty && tags.isEmpty) return null;
      
      return GroqAnalysisResult(summary: summary, tldr: tldr, tags: tags);
      
    } catch (e) {
      debugPrint('Groq analysis error: $e');
      return null;
    }
  }

  /// Validate an API key by making a minimal request
  static Future<bool> validateApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    try {
      final response = await http.get(
        Uri.parse('https://api.groq.com/openai/v1/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Groq validation error: $e');
      return false;
    }
  }
}
