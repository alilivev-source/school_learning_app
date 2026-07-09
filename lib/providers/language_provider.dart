import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class LanguageProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _locale = const Locale('ar', 'SA');

  LanguageProvider(this._prefs) {
    _loadLanguage();
  }

  // Getters
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  // تحميل اللغة
  void _loadLanguage() {
    String? languageCode = _prefs.getString(AppConstants.keyLanguage);
    if (languageCode == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('ar', 'SA');
    }
  }

  // تغيير اللغة
  void setLanguage(String languageCode) {
    if (languageCode == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('ar', 'SA');
    }
    _prefs.setString(AppConstants.keyLanguage, languageCode);
    notifyListeners();
  }

  // تبديل اللغة
  void toggleLanguage() {
    if (isArabic) {
      setLanguage('en');
    } else {
      setLanguage('ar');
    }
  }

  // الحصول على اتجاه النص
  TextDirection get textDirection {
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  // الحصول على اسم اللغة الحالية
  String get currentLanguageName {
    return isArabic ? 'العربية' : 'English';
  }

  // ترجمة النصوص حسب اللغة
  String translate(String arText, String enText) {
    return isArabic ? arText : enText;
  }
}