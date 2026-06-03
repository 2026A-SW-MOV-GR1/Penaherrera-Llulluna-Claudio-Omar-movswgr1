import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/rest_controller.dart';
import '../widgets/custom_text_field.dart';

class RestScreen extends StatelessWidget {
  const RestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RestController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.api, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Conectividad REST',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.idController,
                        label: 'ID del post',
                        hint: 'Ingrese un número',
                        enabled: !controller.isLoading,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: controller.isLoading
                                  ? null
                                  : () => controller.fetchPost(controller.idController.text),
                              icon: const Icon(Icons.download),
                              label: const Text('Obtener'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (controller.isLoading) ...[
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _StatusBanner(message: controller.message),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.titleController,
                        label: 'Title',
                        enabled: !controller.isLoading && controller.currentPost != null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: controller.bodyController,
                        label: 'Body',
                        enabled: !controller.isLoading && controller.currentPost != null,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: (!controller.isLoading && controller.currentPost != null)
                            ? controller.updatePost
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Actualizar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Flujo de demostración:\n1. Ingrese un ID.\n2. Presione Obtener.\n3. Edite title/body.\n4. Presione Actualizar.\n\nJSONPlaceholder responde con éxito, pero no persiste cambios permanentemente.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}

