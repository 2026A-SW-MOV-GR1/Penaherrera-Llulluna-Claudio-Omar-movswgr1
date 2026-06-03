import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secret_storage_service.dart';

class EncryptedStorageService implements SecretStorageService {
  EncryptedStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }
}

