import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'repositories/sql_task_repository.dart';
import 'repositories/hive_task_repository.dart';
import 'controllers/task_controller.dart';
import 'screens/task_screen.dart';
import 'models/task.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive temprano
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskAdapter());
  }

  // Crear repositorios
  final sqlRepo = SqlTaskRepository();
  final hiveRepo = HiveTaskRepository();

  // Inicializar ambos (por simplicidad se inicializan al inicio)
  await sqlRepo.init();
  await hiveRepo.init();

  final controller = TaskController(sqlRepository: sqlRepo, hiveRepository: hiveRepo);
  await controller.loadTasks();

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final TaskController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskController>.value(
      value: controller,
      child: MaterialApp(
        title: 'Persistencia Dual',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const TaskScreen(),
      ),
    );
  }
}


