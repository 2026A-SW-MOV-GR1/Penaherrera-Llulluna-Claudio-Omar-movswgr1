import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';
import 'task_repository.dart';
import 'package:flutter/foundation.dart';

class SqlTaskRepository implements TaskRepository {
  Database? _db;

  @override
  String get name => 'SQLite';

  @override
  Future<void> init() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = p.join(documentsDirectory.path, 'tasks.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT NOT NULL
            )
          ''');
        },
      );
      debugPrint('[DUAL_STORAGE] action=INIT storage=SQL result=SUCCESS');
    } catch (e) {
      debugPrint('[DUAL_STORAGE] action=INIT storage=SQL result=ERROR message=${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<Task>> getAll() async {
    final db = _db;
    if (db == null) return [];
    final maps = await db.query('tasks', orderBy: 'id DESC');
    final tasks = maps.map((m) => Task.fromMap(m)).toList();
    debugPrint('[DUAL_STORAGE] action=READ storage=SQL result=SUCCESS count=${tasks.length}');
    return tasks;
  }

  @override
  Future<Task> create(Task task) async {
    final db = _db;
    if (db == null) throw Exception('DB not initialized');
    final id = await db.insert('tasks', {'title': task.title, 'description': task.description});
    task.id = id;
    debugPrint('[DUAL_STORAGE] action=CREATE storage=SQL result=SUCCESS id=$id');
    return task;
  }

  @override
  Future<Task> update(Task task) async {
    final db = _db;
    if (db == null) throw Exception('DB not initialized');
    await db.update('tasks', {'title': task.title, 'description': task.description}, where: 'id = ?', whereArgs: [task.id]);
    debugPrint('[DUAL_STORAGE] action=UPDATE storage=SQL result=SUCCESS id=${task.id}');
    return task;
  }

  @override
  Future<void> delete(int id) async {
    final db = _db;
    if (db == null) throw Exception('DB not initialized');
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    debugPrint('[DUAL_STORAGE] action=DELETE storage=SQL result=SUCCESS id=$id');
  }

  @override
  Future<void> close() async {
    await _db?.close();
    debugPrint('[DUAL_STORAGE] action=CLOSE storage=SQL result=SUCCESS');
  }
}

