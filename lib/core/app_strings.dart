/// نصوص التطبيق المركزية (ثنائية اللغة)
/// ملاحظة: معظم الشاشات تكتب النصوص مباشرة inline حالياً؛
/// هذا الملف متاح لتوحيد النصوص تدريجياً عند إجراء أي تحديثات مستقبلية.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _strings = {
    'appName': {'ar': 'روضة النور', 'en': 'Rawdat Al-Noor'},
    'home': {'ar': 'الرئيسية', 'en': 'Home'},
    'letters': {'ar': 'الحروف', 'en': 'Letters'},
    'words': {'ar': 'الكلمات', 'en': 'Words'},
    'games': {'ar': 'الألعاب', 'en': 'Games'},
    'stories': {'ar': 'القصص', 'en': 'Stories'},
    'levels': {'ar': 'المستويات', 'en': 'Levels'},
    'store': {'ar': 'المتجر', 'en': 'Store'},
    'profile': {'ar': 'الملف الشخصي', 'en': 'Profile'},
    'settings': {'ar': 'الإعدادات', 'en': 'Settings'},
    'stars': {'ar': 'النجوم', 'en': 'Stars'},
    'next': {'ar': 'التالي', 'en': 'Next'},
    'previous': {'ar': 'السابق', 'en': 'Previous'},
    'back': {'ar': 'العودة', 'en': 'Back'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'confirm': {'ar': 'تأكيد', 'en': 'Confirm'},
    'ok': {'ar': 'حسناً', 'en': 'OK'},
    'playAgain': {'ar': 'العب مرة أخرى', 'en': 'Play Again'},
    'excellent': {'ar': 'ممتاز! 🎉', 'en': 'Excellent! 🎉'},
    'goodJob': {'ar': 'أحسنت! 🏆', 'en': 'Good job! 🏆'},
    'tryAgain': {'ar': 'حاول مرة أخرى', 'en': 'Try again'},
    'correct': {'ar': 'إجابة صحيحة!', 'en': 'Correct!'},
    'loading': {'ar': 'جاري التحميل...', 'en': 'Loading...'},
  };

  static String get(String key, {required bool isArabic}) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[isArabic ? 'ar' : 'en'] ?? key;
  }
}
