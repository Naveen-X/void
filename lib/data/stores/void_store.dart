import '../database/void_database.dart';
import '../models/void_item.dart';

class VoidStore {
  static Future<void> init() async {
    await VoidDatabase.init();
  }

  static Future<List<VoidItem>> all() async {
    return await VoidDatabase.getAllItems();
  }

  static Future<void> add(VoidItem item) async {
    await VoidDatabase.insertItem(item);
  }

  static Future<void> delete(String id) async {
    await VoidDatabase.deleteItem(id);
  }

  static Future<void> deleteMany(Set<String> ids) async {
    await VoidDatabase.deleteManyItems(ids);
  }

  static Future<List<VoidItem>> search(String query) async {
    return await VoidDatabase.searchItems(query);
  }
}