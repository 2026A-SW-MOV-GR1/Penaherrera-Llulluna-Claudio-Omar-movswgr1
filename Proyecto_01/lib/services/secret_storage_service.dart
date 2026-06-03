abstract class SecretStorageService {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
}

