import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _deepgramApiKey = '';
  String _claudeApiKey = '';
  String _language = 'ja';
  bool _isLoaded = false;

  String get deepgramApiKey => _deepgramApiKey;
  String get claudeApiKey => _claudeApiKey;
  String get language => _language;
  bool get isLoaded => _isLoaded;
  bool get isConfigured =>
      _deepgramApiKey.isNotEmpty && _claudeApiKey.isNotEmpty;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _deepgramApiKey = prefs.getString('deepgram_api_key') ?? '';
    _claudeApiKey = prefs.getString('claude_api_key') ?? '';
    _language = prefs.getString('language') ?? 'ja';
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setDeepgramApiKey(String key) async {
    _deepgramApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deepgram_api_key', key);
    notifyListeners();
  }

  Future<void> setClaudeApiKey(String key) async {
    _claudeApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('claude_api_key', key);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }
}
