import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:examen_01/main.dart';
import 'package:examen_01/controllers/task_controller.dart';
import 'package:examen_01/models/task.dart';
import 'package:examen_01/repositories/task_repository.dart';

class _FakeRepo implements TaskRepository {
  final List<Task> _items = [];
  @override
  String get name => 'SQLite';
  @override
  Future<void> init() async {}
  @override
  Future<List<Task>> getAll() async => List<Task>.from(_items);
  @override
  Future<Task> create(Task task) async {
    final created = Task(id: _items.length + 1, title: task.title, description: task.description);
    _items.add(created);
    return created;
  }
  @override
  Future<Task> update(Task task) async => task;
  @override
  Future<void> delete(int id) async => _items.removeWhere((t) => t.id == id);
  @override
  Future<void> close() async {}
}

void main() {
  testWidgets('renders dual persistence home screen', (WidgetTester tester) async {
    final sql = _FakeRepo();
    final hive = _FakeRepo();
    final controller = TaskController(sqlRepository: sql, hiveRepository: hive);
    await controller.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<TaskController>.value(
        value: controller,
        child: MyApp(controller: controller),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Persistencia Dual'), findsOneWidget);
    expect(find.textContaining('Origen actual:'), findsOneWidget);
  });
}
