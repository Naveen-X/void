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

  VoidItem({
    required this.id,
    required this.type,
    required this.content,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.createdAt,
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
    };
  }

  // ---------------- FALLBACK ----------------

  factory VoidItem.fallback(String text) {
    final uri = Uri.tryParse(text);

    return VoidItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'link',
      content: text,
      title: uri?.host ?? text,
      summary: '',
      imageUrl: null,
      createdAt: DateTime.now(),
    );
  }
}
