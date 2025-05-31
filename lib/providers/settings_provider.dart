import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications';

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'zh_TW';
  bool _notificationsEnabled = true;
  final _prefs = SharedPreferences.getInstance();

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? 0];
    _language = prefs.getString(_languageKey) ?? 'zh_TW';
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await _prefs;
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await _prefs;
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.clear();
    await _loadSettings();
  }
}
