import 'dart:convert';
import 'package:hive/hive.dart';
part 'void_item.g.dart';

@HiveType(typeId: 0)
class VoidItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String summary;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  final List<double>? embedding;

  VoidItem({
    required this.id,
    required this.type,
    required this.content,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.createdAt,
    this.tags = const [],
    this.embedding,
  });

  factory VoidItem.fromJson(Map<String, dynamic> json) {
    return VoidItem(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: json['tags'] != null
          ? List<String>.from(jsonDecode(json['tags']))
          : [],
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
      'tags': jsonEncode(tags),
      'embedding': embedding != null ? jsonEncode(embedding) : null,
    };
  }

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

  /// Creates a copy of this item with the given fields replaced
  VoidItem copyWith({
    String? id,
    String? type,
    String? content,
    String? title,
    String? summary,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? tags,
    List<double>? embedding,
  }) {
    return VoidItem(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      embedding: embedding ?? this.embedding,
    );
  }
}
