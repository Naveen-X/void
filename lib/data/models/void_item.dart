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
  final String? summary;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(9)
  final String? tldr;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  final List<double>? embedding;

  @HiveField(10, defaultValue: false)
  final bool isDeleted;

  VoidItem({
    required this.id,
    required this.type,
    required this.content,
    required this.title,
    this.summary,
    this.imageUrl,
    this.tldr,
    required this.createdAt,
    this.tags = const [],
    this.embedding,
    this.isDeleted = false,
  });

  factory VoidItem.fromJson(Map<String, dynamic> json) {
    return VoidItem(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      title: json['title'] ?? '',
      summary: json['summary'],
      imageUrl: json['imageUrl'],
      tldr: json['tldr'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: json['tags'] != null
          ? List<String>.from(jsonDecode(json['tags']))
          : [],
      embedding: json['embedding'] != null
          ? (jsonDecode(json['embedding']) as List)
              .map((e) => (e as num).toDouble())
              .toList()
          : null,
      isDeleted: json['isDeleted'] == 1 || json['isDeleted'] == true || json['isDeleted'] == 'true',
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
      'tldr': tldr,
      'createdAt': createdAt.toIso8601String(),
      'tags': jsonEncode(tags),
      'embedding': embedding != null ? jsonEncode(embedding) : null,
      'isDeleted': isDeleted ? 1 : 0,
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
      tldr: '',
      imageUrl: null,
      createdAt: DateTime.now(),
      tags: [],
      embedding: null,
      isDeleted: false,
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
    String? tldr,
    DateTime? createdAt,
    List<String>? tags,
    List<double>? embedding,
    bool? isDeleted,
  }) {
    return VoidItem(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      tldr: tldr ?? this.tldr,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      embedding: embedding ?? this.embedding,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
