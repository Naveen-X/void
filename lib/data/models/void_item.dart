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
  // 🔥 REMOVED: final List<String> tags;
  // 🔥 REMOVED: final List<double>? embedding;

  VoidItem({
    required this.id,
    required this.type,
    required this.content,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.createdAt,
    // 🔥 REMOVED: this.tags = const [],
    // 🔥 REMOVED: this.embedding,
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
      // 🔥 REMOVED: tags: List<String>.from(json['tags'] ?? []),
      // 🔥 REMOVED: embedding: (json['embedding'] as List?)?.map((e) => (e as num).toDouble()).toList(),
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
      // 🔥 REMOVED: 'tags': tags,
      // 🔥 REMOVED: 'embedding': embedding,
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
      // 🔥 REMOVED: tags: [],
      // 🔥 REMOVED: embedding: null,
    );
  }
}