import 'package:flutter_test/flutter_test.dart';
import 'package:examen_01/controllers/task_controller.dart';
import 'package:examen_01/models/task.dart';
import 'package:examen_01/repositories/task_repository.dart';

class FakeSqlRepo implements TaskRepository {
  final List<Task> _store = [];
  @override
  String get name => 'SQLite';

  @override
  Future<Task> create(Task task) async {
    final newTask = Task(id: _store.length + 1, title: task.title, description: task.description);
    _store.add(newTask);
    return newTask;
  }

  @override
  Future<void> delete(int id) async {
    _store.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<Task>> getAll() async {
    return List.from(_store);
  }

  @override
  Future<void> init() async {}

  @override
  Future<Task> update(Task task) async {
    final idx = _store.indexWhere((t) => t.id == task.id);
    if (idx >= 0) _store[idx] = task;
    return task;
  }

  @override
  Future<void> close() async {}
}

class FakeHiveRepo implements TaskRepository {
  final List<Task> _store = [];
  @override
  String get name => 'Hive NoSQL';

  @override
  Future<Task> create(Task task) async {
    final newTask = Task(id: _store.length + 1, title: task.title, description: task.description);
    _store.add(newTask);
    return newTask;
  }

  @override
  Future<void> delete(int id) async {
    _store.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<Task>> getAll() async {
    return List.from(_store);
  }

  @override
  Future<void> init() async {}

  @override
  Future<Task> update(Task task) async {
    final idx = _store.indexWhere((t) => t.id == task.id);
    if (idx >= 0) _store[idx] = task;
    return task;
  }

  @override
  Future<void> close() async {}
}

void main() {
  test('SQLite and Hive are independent', () async {
    final sql = FakeSqlRepo();
    final hive = FakeHiveRepo();
    final controller = TaskController(sqlRepository: sql as dynamic, hiveRepository: hive as dynamic);
    await controller.init();

    // start in SQL
    expect(controller.storageType, StorageType.sql);
    await controller.createTask('Tarea SQL', 'desde SQL');
    expect(controller.tasks.length, 1);
    expect(controller.tasks.first.title, 'Tarea SQL');

    // switch to Hive -> should be empty
    await controller.switchStorage(StorageType.nosql);
    expect(controller.tasks.isEmpty, true);

    // create in Hive
    await controller.createTask('Tarea Hive', 'desde Hive');
    expect(controller.tasks.length, 1);
    expect(controller.tasks.first.title, 'Tarea Hive');

    // switch back to SQL -> only SQL task
    await controller.switchStorage(StorageType.sql);
    expect(controller.tasks.length, 1);
    expect(controller.tasks.first.title, 'Tarea SQL');
  });

  test('Switch loads correct list', () async {
    final sql = FakeSqlRepo();
    final hive = FakeHiveRepo();
    final controller = TaskController(sqlRepository: sql as dynamic, hiveRepository: hive as dynamic);
    await controller.init();

    await controller.createTask('S1', 'a');
    await controller.switchStorage(StorageType.nosql);
    await controller.createTask('H1', 'b');

    await controller.switchStorage(StorageType.sql);
    expect(controller.tasks.length, 1);
    expect(controller.tasks.first.title, 'S1');

    await controller.switchStorage(StorageType.nosql);
    expect(controller.tasks.length, 1);
    expect(controller.tasks.first.title, 'H1');
  });
}

