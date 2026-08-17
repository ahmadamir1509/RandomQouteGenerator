import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController() {
    _load();
  }

  static const _keyTheme = 'settings_theme'; // 'system'|'light'|'dark'
  static const _keyBackground = 'settings_background';
  static const _keyProfileName = 'profile_name';
  static const _keyProfilePhone = 'profile_phone';
  static const _keySplash3D = 'settings_splash_3d';

  ThemeMode _themeMode = ThemeMode.system;
  int _backgroundVariant = 0;
  String _profileName = '';
  String _profilePhone = '';
  bool _splash3D = true;

  ThemeMode get themeMode => _themeMode;
  int get backgroundVariant => _backgroundVariant;
  String get profileName => _profileName;
  String get profilePhone => _profilePhone;
  bool get splash3D => _splash3D;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_keyTheme) ?? 'system';
    _themeMode = switch (t) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _backgroundVariant = prefs.getInt(_keyBackground) ?? 0;
    _profileName = prefs.getString(_keyProfileName) ?? '';
    _profilePhone = prefs.getString(_keyProfilePhone) ?? '';
    _splash3D = prefs.getBool(_keySplash3D) ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    final prefs = await SharedPreferences.getInstance();
    final s = m == ThemeMode.light
        ? 'light'
        : (m == ThemeMode.dark ? 'dark' : 'system');
    await prefs.setString(_keyTheme, s);
    notifyListeners();
  }

  Future<void> setBackgroundVariant(int v) async {
    _backgroundVariant = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBackground, v);
    notifyListeners();
  }

  Future<void> setProfile(String name, String phone) async {
    _profileName = name;
    _profilePhone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileName, name);
    await prefs.setString(_keyProfilePhone, phone);
    notifyListeners();
  }

  Future<void> setSplash3D(bool enabled) async {
    _splash3D = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySplash3D, enabled);
    notifyListeners();
  }
}
