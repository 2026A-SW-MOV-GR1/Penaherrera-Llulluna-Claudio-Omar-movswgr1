import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int? _editingId;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _startEdit(Task task) {
    setState(() {
      _editingId = task.id;
      _titleController.text = task.title;
      _descController.text = task.description;
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _titleController.clear();
      _descController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TaskController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistencia Dual'),
        actions: [
          Row(
            children: [
              Text(controller.storageType == StorageType.sql ? 'SQLite' : 'Hive NoSQL'),
              Switch(
                value: controller.storageType == StorageType.sql,
                onChanged: (value) {
                  controller.switchStorage(value ? StorageType.sql : StorageType.nosql);
                },
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text('Origen actual: ${controller.activeStorageName}'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    final desc = _descController.text.trim();
                    if (title.isEmpty) return;
                    if (_editingId == null) {
                      await controller.createTask(title, desc);
                    } else {
                      final task = Task(id: _editingId, title: title, description: desc);
                      await controller.updateTask(task);
                    }
                    _clearForm();
                  },
                  child: Text(_editingId == null ? 'Guardar' : 'Actualizar'),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: _clearForm, child: const Text('Limpiar'))
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: controller.tasks.isEmpty
                  ? const Center(child: Text('No hay tareas'))
                  : ListView.builder(
                      itemCount: controller.tasks.length,
                      itemBuilder: (context, index) {
                        final t = controller.tasks[index];
                        return Card(
                          child: ListTile(
                            title: Text(t.title),
                            subtitle: Text(t.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _startEdit(t),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    if (t.id != null) await controller.deleteTask(t.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

