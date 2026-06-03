import '../models/task.dart';

abstract class TaskRepository {
  String get name;

  Future<void> init();

  Future<List<Task>> getAll();

  Future<Task> create(Task task);

  Future<Task> update(Task task);

  Future<void> delete(int id);

  Future<void> close();
}

