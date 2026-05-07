import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyService {
  static const _key = 'claude_api_key';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> read() => _storage.read(key: _key);

  static Future<void> write(String apiKey) =>
      _storage.write(key: _key, value: apiKey);

  static Future<void> delete() => _storage.delete(key: _key);
}
