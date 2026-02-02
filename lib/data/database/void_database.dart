import 'dart:developer' as developer;
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/void_item.dart';

class VoidDatabase {
  static Database? _database;

  /// Global access to the database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Explicit initialization called by VoidStore
  static Future<void> init() async {
    await database; 
  }

  static Future<Database> _initDatabase() async {
    // 1. Get the support directory (Industry standard for internal app databases)
    final Directory supportDir = await getApplicationSupportDirectory();
    
    // 2. Ensure the directory exists. FFI driver is strict and won't create 
    // the parent folder automatically, leading to Error 14 (CANTOPEN).
    if (!await supportDir.exists()) {
      await supportDir.create(recursive: true);
    }

    // 3. Define path. Incremented version to v7 to ensure a clean schema start.
    final String path = join(supportDir.path, 'void_vault_v7.db'); 
    developer.log('Opening database at: $path', name: 'VoidDB');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // Enable foreign keys for data integrity
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        developer.log('Building FTS5 Schema...', name: 'VoidDB');
        
        // --- PRIMARY DATA TABLE ---
        await db.execute('''
          CREATE TABLE void_items (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            content TEXT NOT NULL,
            title TEXT NOT NULL,
            summary TEXT NOT NULL,
            imageUrl TEXT,
            createdAt TEXT NOT NULL,
            tags TEXT NOT NULL,
            embedding TEXT
          )
        ''');

        // --- FTS5 VIRTUAL TABLE ---
        // Removed 'UNSTORED' for maximum compatibility across SQLite versions.
        await db.execute('''
          CREATE VIRTUAL TABLE void_items_fts USING fts5(
            id, 
            title,
            summary,
            content,
            tags,
            content='void_items',
            tokenize='unicode61 remove_diacritics 1'
          )
        ''');

        // --- SYNCHRONIZATION TRIGGERS ---
        
        // Trigger: After Insert
        await db.execute('''
          CREATE TRIGGER void_items_ai AFTER INSERT ON void_items BEGIN
            INSERT INTO void_items_fts(id, title, summary, content, tags) 
            VALUES (new.id, new.title, new.summary, new.content, new.tags);
          END;
        ''');

        // Trigger: After Delete
        await db.execute('''
          CREATE TRIGGER void_items_ad AFTER DELETE ON void_items BEGIN
            INSERT INTO void_items_fts(void_items_fts, id, title, summary, content, tags) 
            VALUES('delete', old.id, old.title, old.summary, old.content, old.tags);
          END;
        ''');

        // Trigger: After Update
        await db.execute('''
          CREATE TRIGGER void_items_au AFTER UPDATE ON void_items BEGIN
            INSERT INTO void_items_fts(void_items_fts, id, title, summary, content, tags) 
            VALUES('delete', old.id, old.title, old.summary, old.content, old.tags);
            INSERT INTO void_items_fts(id, title, summary, content, tags) 
            VALUES (new.id, new.title, new.summary, new.content, new.tags);
          END;
        ''');
      },
    );
  }

  // ---------------------------------------------------------
  // CRUD OPERATIONS
  // ---------------------------------------------------------

  static Future<void> insertItem(VoidItem item) async {
    final db = await database;
    await db.insert(
      'void_items', 
      item.toJson(), 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  static Future<List<VoidItem>> getAllItems() async {
    final db = await database;
    final res = await db.query('void_items', orderBy: 'createdAt DESC');
    return res.map((e) => VoidItem.fromJson(e)).toList();
  }

  static Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('void_items', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteManyItems(Set<String> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final String whereClause = 'id IN (${ids.map((_) => '?').join(',')})';
    await db.delete('void_items', where: whereClause, whereArgs: ids.toList());
  }

  /// High-performance Full-Text Search using the FTS5 virtual table
  static Future<List<VoidItem>> searchItems(String query) async {
    final db = await database;
    if (query.trim().isEmpty) return getAllItems();
    
    // Uses prefix matching (e.g., "search*" matches "searching", "searchable")
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT T1.* FROM void_items AS T1
      JOIN void_items_fts AS T2 ON T1.id = T2.id
      WHERE T2.void_items_fts MATCH ?
      ORDER BY T1.createdAt DESC
    ''', ['"${query.trim()}*"']);

    return maps.map((e) => VoidItem.fromJson(e)).toList();
  }
}