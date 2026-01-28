import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/void_item.dart';

class VoidStore {
  static late File _file;
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;

    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/void_items.json');

    if (!_file.existsSync()) {
      await _file.writeAsString('[]');
    }

    _inited = true;
  }

  static Future<List<VoidItem>> all() async {
    await init();
    final raw = await _file.readAsString();
    final list = jsonDecode(raw) as List;
    return list.map((e) => VoidItem.fromJson(e)).toList().reversed.toList();
  }

  static Future<void> add(VoidItem item) async {
    await init();
    final raw = await _file.readAsString();
    final list = jsonDecode(raw) as List;

    list.add(item.toJson());

    await _file.writeAsString(jsonEncode(list));
  }

  static Future<void> delete(String id) async {
    await init();
    final raw = await _file.readAsString();
    List list = jsonDecode(raw);
    list.removeWhere((item) => item['id'] == id);
    await _file.writeAsString(jsonEncode(list));
  }
}
