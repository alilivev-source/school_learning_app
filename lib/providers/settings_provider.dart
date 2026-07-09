import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// يدير إعدادات عامة إضافية للتطبيق (حالياً: الوضع الليلي)
/// إعدادات الصوت واللغة تُدار عبر AudioProvider و LanguageProvider تحديداً
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _isDarkMode = false;

  SettingsProvider(this._prefs) {
    _isDarkMode = _prefs.getBool(AppConstants.keyDarkMode) ?? false;
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool(AppConstants.keyDarkMode, value);
    notifyListeners();
  }
}
