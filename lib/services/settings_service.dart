import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeChoice { dark, light, system }

/// Which AI engine the user wants to use.
enum EngineChoice {
  groq, // online, via Groq API
  onDevice, // offline, local model
}

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _kGroqKey = 'groq_api_key';
  static const _kUserName = 'user_name';
  static const _kTheme = 'theme_choice';
  static const _kEngine = 'engine_choice';
  static const _kActiveModelId = 'active_model_id';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ---- API keys (secure) ----
  Future<String?> getGroqKey() => _secure.read(key: _kGroqKey);
  Future<void> setGroqKey(String value) => _secure.write(key: _kGroqKey, value: value);

  Future<String?> getUserName() => _secure.read(key: _kUserName);
  Future<void> setUserName(String value) => _secure.write(key: _kUserName, value: value);

  // ---- Theme (prefs) ----
  Future<ThemeChoice> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kTheme) ?? 'dark';
    return ThemeChoice.values.firstWhere((t) => t.name == raw, orElse: () => ThemeChoice.dark);
  }

  Future<void> setTheme(ThemeChoice c) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, c.name);
  }

  // ---- Engine choice (prefs) ----
  Future<EngineChoice> getEngine() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kEngine) ?? 'groq';
    return EngineChoice.values.firstWhere((e) => e.name == raw, orElse: () => EngineChoice.groq);
  }

  Future<void> setEngine(EngineChoice c) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEngine, c.name);
  }

  // ---- Active on-device model id (prefs) ----
  Future<String?> getActiveModelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kActiveModelId);
  }

  Future<void> setActiveModelId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_kActiveModelId);
    } else {
      await prefs.setString(_kActiveModelId, id);
    }
  }
}
