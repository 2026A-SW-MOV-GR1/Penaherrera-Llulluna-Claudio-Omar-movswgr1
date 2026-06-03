import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

enum StorageType { sql, nosql }

class TaskController extends ChangeNotifier {
  final TaskRepository sqlRepository;
  final TaskRepository hiveRepository;

  late TaskRepository _activeRepository;
  StorageType storageType;

  List<Task> tasks = [];

  TaskController({required this.sqlRepository, required this.hiveRepository, this.storageType = StorageType.sql}) {
    _activeRepository = storageType == StorageType.sql ? sqlRepository : hiveRepository;
  }

  String get activeStorageName => _activeRepository.name;

  Future<void> init() async {
    await sqlRepository.init();
    await hiveRepository.init();
    _activeRepository = storageType == StorageType.sql ? sqlRepository : hiveRepository;
    await loadTasks();
  }

  Future<void> switchStorage(StorageType newType) async {
    final old = storageType;
    storageType = newType;
    _activeRepository = storageType == StorageType.sql ? sqlRepository : hiveRepository;
    await loadTasks();
    debugPrint('[DUAL_STORAGE] action=SWITCH from=${old.name} to=${newType.name} result=SUCCESS');
    notifyListeners();
  }

  Future<void> loadTasks() async {
    tasks = await _activeRepository.getAll();
    notifyListeners();
  }

  Future<void> createTask(String title, String description) async {
    final task = Task(title: title, description: description);
    final created = await _activeRepository.create(task);
    debugPrint('[DUAL_STORAGE] action=CREATE storage=${_activeRepository.name} result=SUCCESS id=${created.id}');
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final updated = await _activeRepository.update(task);
    debugPrint('[DUAL_STORAGE] action=UPDATE storage=${_activeRepository.name} result=SUCCESS id=${updated.id}');
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _activeRepository.delete(id);
    debugPrint('[DUAL_STORAGE] action=DELETE storage=${_activeRepository.name} result=SUCCESS id=$id');
    await loadTasks();
  }
}


