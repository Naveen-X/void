import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'package:void_space/data/models/void_item.dart';

class LinkMetadataService {
  static Future<VoidItem> fetch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return VoidItem.fallback(url);
    }

    final res = await http.get(uri);
    final body = utf8.decode(res.bodyBytes);

    final doc = html.parse(body);

    String? pickMeta(String key) {
      return doc
          .querySelector('meta[property="$key"]')
          ?.attributes['content'];
    }

    final title =
        pickMeta('og:title') ??
        doc.querySelector('title')?.text ??
        uri.host;

    final summary =
        pickMeta('og:description') ??
        pickMeta('description') ??
        '';

    final imageUrl = pickMeta('og:image');

    return VoidItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'link',
      content: url,
      title: title.trim(),
      summary: summary.trim(),
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }
}
