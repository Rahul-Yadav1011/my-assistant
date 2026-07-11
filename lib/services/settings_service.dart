import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeChoice { dark, light, system }

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _kGeminiKey = 'gemini_api_key';
  static const _kGroqKey = 'groq_api_key';
  static const _kUserName = 'user_name';
  static const _kTheme = 'theme_choice';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getGeminiKey() => _secure.read(key: _kGeminiKey);
  Future<void> setGeminiKey(String value) => _secure.write(key: _kGeminiKey, value: value);
  Future<String?> getGroqKey() => _secure.read(key: _kGroqKey);
  Future<void> setGroqKey(String value) => _secure.write(key: _kGroqKey, value: value);
  Future<String?> getUserName() => _secure.read(key: _kUserName);
  Future<void> setUserName(String value) => _secure.write(key: _kUserName, value: value);

  Future<ThemeChoice> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kTheme) ?? 'dark';
    return ThemeChoice.values.firstWhere((t) => t.name == raw, orElse: () => ThemeChoice.dark);
  }

  Future<void> setTheme(ThemeChoice c) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, c.name);
  }
}
