import 'package:flutter/material.dart';

import '../services/datastore_service.dart';
import '../services/encrypted_storage_service.dart';
import '../services/secret_storage_service.dart';
import '../services/shared_preferences_service.dart';

class SecretsController extends ChangeNotifier {
  static const String sharedPreferencesStorage = 'SharedPreferences';
  static const String dataStoreStorage = 'DataStore';
  static const String encryptedSharedPreferencesStorage = 'EncryptedSharedPreferences';

  SecretsController()
      : _sharedPreferencesService = SharedPreferencesService(),
        _dataStoreService = DataStoreService(),
        _encryptedStorageService = EncryptedStorageService();

  final SecretStorageService _sharedPreferencesService;
  final SecretStorageService _dataStoreService;
  final SecretStorageService _encryptedStorageService;

  String selectedStorage = sharedPreferencesStorage;
  bool isLoading = false;
  String message = 'Seleccione un mecanismo para guardar o recuperar secretos.';
  String? recoveredValue;

  Future<void> saveSecret(String key, String value) async {
    if (isLoading) return;

    final trimmedKey = key.trim();
    final trimmedValue = value.trim();

    if (trimmedKey.isEmpty) {
      _setMessage('La llave no puede estar vacía.');
      debugPrint('[SECRETS] action=SAVE storage=$selectedStorage key=EMPTY result=ERROR message=EMPTY_KEY');
      return;
    }

    if (trimmedValue.isEmpty) {
      _setMessage('El valor no puede estar vacío.');
      debugPrint('[SECRETS] action=SAVE storage=$selectedStorage key=$trimmedKey result=ERROR message=EMPTY_VALUE');
      return;
    }

    _setLoading(true, 'Guardando dato en $selectedStorage...');

    try {
      final storage = _storageFor(selectedStorage);
      await storage.save(trimmedKey, trimmedValue);
      recoveredValue = null;
      _setMessage('Dato guardado correctamente en $selectedStorage');
      debugPrint('[SECRETS] action=SAVE storage=$selectedStorage key=$trimmedKey result=SUCCESS');
    } catch (error) {
      _setMessage('No se pudo guardar el secreto');
      debugPrint('[SECRETS] action=ERROR storage=$selectedStorage key=$trimmedKey message=$error');
    } finally {
      _setLoading(false, message);
    }
  }

  Future<void> recoverSecret(String key) async {
    if (isLoading) return;

    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      _setMessage('La llave no puede estar vacía.');
      debugPrint('[SECRETS] action=READ storage=$selectedStorage key=EMPTY result=ERROR message=EMPTY_KEY');
      return;
    }

    _setLoading(true, 'Recuperando dato desde $selectedStorage...');

    try {
      final storage = _storageFor(selectedStorage);
      final value = await storage.read(trimmedKey);
      if (value == null) {
        recoveredValue = null;
        _setMessage('Secreto no encontrado en este almacenamiento');
        debugPrint('[SECRETS] action=READ storage=$selectedStorage key=$trimmedKey result=NOT_FOUND');
      } else {
        recoveredValue = value;
        _setMessage('Valor recuperado');
        debugPrint('[SECRETS] action=READ storage=$selectedStorage key=$trimmedKey result=SUCCESS');
      }
    } catch (error) {
      recoveredValue = null;
      _setMessage('No se pudo recuperar el secreto');
      debugPrint('[SECRETS] action=ERROR storage=$selectedStorage key=$trimmedKey message=$error');
    } finally {
      _setLoading(false, message);
    }
  }

  void changeStorage(String storage) {
    if (selectedStorage == storage) return;
    selectedStorage = storage;
    recoveredValue = null;
    _setMessage('Almacenamiento seleccionado: $selectedStorage');
  }

  SecretStorageService _storageFor(String storage) {
    switch (storage) {
      case dataStoreStorage:
        return _dataStoreService;
      case encryptedSharedPreferencesStorage:
        return _encryptedStorageService;
      case sharedPreferencesStorage:
      default:
        return _sharedPreferencesService;
    }
  }

  void _setMessage(String newMessage) {
    message = newMessage;
    notifyListeners();
  }

  void _setLoading(bool value, String newMessage) {
    isLoading = value;
    message = newMessage;
    notifyListeners();
  }
}

