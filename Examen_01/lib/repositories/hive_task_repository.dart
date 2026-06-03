import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../models/task.g.dart';
import 'task_repository.dart';
import 'package:flutter/foundation.dart';

class HiveTaskRepository implements TaskRepository {
  Box<Task>? _box;

  @override
  String get name => 'Hive NoSQL';

  @override
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
      }
      _box = await Hive.openBox<Task>('tasks_box');
      debugPrint('[DUAL_STORAGE] action=INIT storage=NOSQL result=SUCCESS');
    } catch (e) {
      debugPrint('[DUAL_STORAGE] action=INIT storage=NOSQL result=ERROR message=${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<Task>> getAll() async {
    final box = _box;
    if (box == null) return [];
    final tasks = box.values.map((t) => Task(id: t.id, title: t.title, description: t.description)).toList().reversed.toList();
    debugPrint('[DUAL_STORAGE] action=READ storage=NOSQL result=SUCCESS count=${tasks.length}');
    return tasks;
  }

  @override
  Future<Task> create(Task task) async {
    final box = _box;
    if (box == null) throw Exception('Hive not initialized');
    final key = await box.add(task);
    task.id = key;
    await box.put(key, task);
    debugPrint('[DUAL_STORAGE] action=CREATE storage=NOSQL result=SUCCESS id=${task.id}');
    return task;
  }

  @override
  Future<Task> update(Task task) async {
    final box = _box;
    if (box == null) throw Exception('Hive not initialized');
    if (task.id == null) throw Exception('Task.id is null');
    await box.put(task.id, task);
    debugPrint('[DUAL_STORAGE] action=UPDATE storage=NOSQL result=SUCCESS id=${task.id}');
    return task;
  }

  @override
  Future<void> delete(int id) async {
    final box = _box;
    if (box == null) throw Exception('Hive not initialized');
    await box.delete(id);
    debugPrint('[DUAL_STORAGE] action=DELETE storage=NOSQL result=SUCCESS id=$id');
  }

  @override
  Future<void> close() async {
    await _box?.close();
    debugPrint('[DUAL_STORAGE] action=CLOSE storage=NOSQL result=SUCCESS');
  }
}

