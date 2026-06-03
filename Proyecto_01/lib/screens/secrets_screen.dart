import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/secrets_controller.dart';
import '../widgets/custom_text_field.dart';

class SecretsScreen extends StatefulWidget {
  const SecretsScreen({super.key});

  @override
  State<SecretsScreen> createState() => _SecretsScreenState();
}

class _SecretsScreenState extends State<SecretsScreen> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecretsController>(
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
                          const Icon(Icons.lock, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Gestión de Secretos y Configuración',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        avatar: const Icon(Icons.storage, size: 18),
                        label: Text('Almacenamiento seleccionado: ${controller.selectedStorage}'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: ValueKey(controller.selectedStorage),
                        initialValue: controller.selectedStorage,
                        decoration: const InputDecoration(
                          labelText: 'Mecanismo de almacenamiento',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: SecretsController.sharedPreferencesStorage,
                            child: Text(SecretsController.sharedPreferencesStorage),
                          ),
                          DropdownMenuItem(
                            value: SecretsController.dataStoreStorage,
                            child: Text(SecretsController.dataStoreStorage),
                          ),
                          DropdownMenuItem(
                            value: SecretsController.encryptedSharedPreferencesStorage,
                            child: Text(SecretsController.encryptedSharedPreferencesStorage),
                          ),
                        ],
                        onChanged: controller.isLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  controller.changeStorage(value);
                                }
                              },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _keyController,
                        label: 'Llave',
                        enabled: !controller.isLoading,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _valueController,
                        label: 'Valor',
                        enabled: !controller.isLoading,
                      ),
                      const SizedBox(height: 16),
                      if (controller.isLoading) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                      ],
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: controller.isLoading
                                ? null
                                : () => controller.saveSecret(_keyController.text, _valueController.text),
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar'),
                          ),
                          OutlinedButton.icon(
                            onPressed: controller.isLoading
                                ? null
                                : () => controller.recoverSecret(_keyController.text),
                            icon: const Icon(Icons.search),
                            label: const Text('Recuperar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _StatusBanner(message: controller.message),
                      const SizedBox(height: 12),
                      if (controller.recoveredValue != null)
                        Card(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Valor recuperado: ${controller.recoveredValue}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                    'La recuperación siempre depende de la llave escrita y del almacenamiento seleccionado.\nNo se listan secretos ni se muestran otras llaves existentes.',
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
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onTertiaryContainer),
      ),
    );
  }
}




