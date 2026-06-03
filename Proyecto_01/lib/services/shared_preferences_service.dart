import 'package:shared_preferences/shared_preferences.dart';

import 'secret_storage_service.dart';

class SharedPreferencesService implements SecretStorageService {
  @override
  Future<void> save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}

