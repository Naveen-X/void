import 'dart:convert';

class VoidItem {
  final String id;

  /// note | link | image
  final String type;

  /// Main payload
  /// - note  → text
  /// - link  → url
  /// - image → base64 / path
  final String content;

  final String title;
  final String summary;
  final String? imageUrl;

  final DateTime createdAt;
  final List<String> tags; // Re-added
  final List<double>? embedding; // Re-added

  VoidItem({
    required this.id,
    required this.type,
    required this.content,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.createdAt,
    this.tags = const [], // Default to empty list
    this.embedding,
  });

  // ---------------- JSON ----------------

  factory VoidItem.fromJson(Map<String, dynamic> json) {
    return VoidItem(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      // Deserialize tags from JSON string
      tags: json['tags'] != null
          ? List<String>.from(jsonDecode(json['tags']))
          : [],
      // Deserialize embedding from JSON string
      embedding: json['embedding'] != null
          ? (jsonDecode(json['embedding']) as List)
              .map((e) => (e as num).toDouble())
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      // Serialize tags to JSON string for storage
      'tags': jsonEncode(tags),
      // Serialize embedding to JSON string for storage
      'embedding': embedding != null ? jsonEncode(embedding) : null,
    };
  }

  // ---------------- FALLBACK ----------------

  factory VoidItem.fallback(String text, {String type = 'note'}) {
    final uri = Uri.tryParse(text);

    return VoidItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: text,
      title: uri?.host ?? text.split('\n').first,
      summary: '',
      imageUrl: null,
      createdAt: DateTime.now(),
      tags: [],
      embedding: null,
    );
  }
}