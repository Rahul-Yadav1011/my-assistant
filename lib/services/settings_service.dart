import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _kGeminiKey = 'gemini_api_key';
  static const _kGroqKey = 'groq_api_key';
  static const _kUserName = 'user_name';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getGeminiKey() => _storage.read(key: _kGeminiKey);
  Future<void> setGeminiKey(String value) =>
      _storage.write(key: _kGeminiKey, value: value);

  Future<String?> getGroqKey() => _storage.read(key: _kGroqKey);
  Future<void> setGroqKey(String value) =>
      _storage.write(key: _kGroqKey, value: value);

  Future<String?> getUserName() => _storage.read(key: _kUserName);
  Future<void> setUserName(String value) =>
      _storage.write(key: _kUserName, value: value);

  Future<bool> hasAnyLlmKey() async {
    final g = await getGeminiKey();
    final gr = await getGroqKey();
    return (g != null && g.isNotEmpty) || (gr != null && gr.isNotEmpty);
  }
}
