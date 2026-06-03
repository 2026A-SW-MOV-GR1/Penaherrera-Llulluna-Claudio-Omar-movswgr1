import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import 'secret_storage_service.dart';

class DataStoreService implements SecretStorageService {
  SharedPreferencesAsync get _prefs => SharedPreferencesAsync(
        options: const SharedPreferencesAsyncAndroidOptions(
          backend: SharedPreferencesAndroidBackendLibrary.DataStore,
        ),
      );

  @override
  Future<void> save(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> read(String key) async {
    return _prefs.getString(key);
  }
}



