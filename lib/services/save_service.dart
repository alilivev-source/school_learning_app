import 'package:shared_preferences/shared_preferences.dart';

import '../game/weapons.dart';

/// خدمة مسؤولة عن حفظ واسترجاع كل تقدم اللاعب باستخدام SharedPreferences:
/// - آخر مرحلة مفتوحة، وأعلى نتيجة لكل مرحلة.
/// - تفضيلات الصوت والموسيقى.
/// - رصيد العملات/الجواهر الدائم (بنك المتجر) ومستويات ترقية كل سلاح.
class SaveService {
  static const _unlockedLevelKey = 'unlocked_level';
  static const _highScorePrefix = 'high_score_level_';
  static const _soundEnabledKey = 'sound_enabled';
  static const _musicEnabledKey = 'music_enabled';
  static const _totalCoinsKey = 'total_coins';
  static const _totalGemsKey = 'total_gems';
  static const _weaponLevelPrefix = 'weapon_level_';

  static const int maxWeaponLevel = 5;

  // -------------------------------------------------------------------
  // تقدم المراحل
  // -------------------------------------------------------------------

  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unlockedLevelKey) ?? 1;
  }

  static Future<void> unlockLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_unlockedLevelKey) ?? 1;
    if (level > current) {
      await prefs.setInt(_unlockedLevelKey, level);
    }
  }

  static Future<int> getHighScore(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_highScorePrefix$level') ?? 0;
  }

  static Future<void> setHighScoreIfBetter(int level, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('$_highScorePrefix$level') ?? 0;
    if (score > current) {
      await prefs.setInt('$_highScorePrefix$level', score);
    }
  }

  // -------------------------------------------------------------------
  // تفضيلات الصوت والموسيقى (منفصلة حتى يقدر اللاعب يوقف الموسيقى ويبقي المؤثرات مثلاً)
  // -------------------------------------------------------------------

  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  static Future<bool> isMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  static Future<void> setMusicEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, value);
  }

  // -------------------------------------------------------------------
  // بنك العملات/الجواهر الدائم (يُستخدم في متجر الترقيات)
  // -------------------------------------------------------------------

  static Future<int> getTotalCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalCoinsKey) ?? 0;
  }

  static Future<int> getTotalGems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalGemsKey) ?? 0;
  }

  static Future<int> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final total = (prefs.getInt(_totalCoinsKey) ?? 0) + amount;
    await prefs.setInt(_totalCoinsKey, total);
    return total;
  }

  static Future<int> addGems(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final total = (prefs.getInt(_totalGemsKey) ?? 0) + amount;
    await prefs.setInt(_totalGemsKey, total);
    return total;
  }

  /// يحاول خصم عملات ذهبية؛ يرجع true إذا كان الرصيد كافيًا ونجح الخصم.
  static Future<bool> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final total = prefs.getInt(_totalCoinsKey) ?? 0;
    if (total < amount) return false;
    await prefs.setInt(_totalCoinsKey, total - amount);
    return true;
  }

  /// يحاول خصم جواهر؛ يرجع true إذا كان الرصيد كافيًا ونجح الخصم.
  static Future<bool> spendGems(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final total = prefs.getInt(_totalGemsKey) ?? 0;
    if (total < amount) return false;
    await prefs.setInt(_totalGemsKey, total - amount);
    return true;
  }

  // -------------------------------------------------------------------
  // مستويات ترقية الأسلحة (1 إلى maxWeaponLevel)
  // -------------------------------------------------------------------

  static Future<int> getWeaponLevel(WeaponType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_weaponLevelPrefix${type.name}') ?? 1;
  }

  static Future<Map<WeaponType, int>> getAllWeaponLevels() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final type in WeaponType.values) type: prefs.getInt('$_weaponLevelPrefix${type.name}') ?? 1,
    };
  }

  /// تكلفة ترقية سلاح من مستواه الحالي إلى ما بعده (تزيد كل مستوى).
  static int upgradeCost(int currentLevel) => currentLevel * 40;

  /// يحاول ترقية سلاح معيّن باستخدام العملات المخزّنة. يرجع true عند النجاح.
  static Future<bool> tryUpgradeWeapon(WeaponType type) async {
    final currentLevel = await getWeaponLevel(type);
    if (currentLevel >= maxWeaponLevel) return false;

    final cost = upgradeCost(currentLevel);
    final success = await spendCoins(cost);
    if (!success) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_weaponLevelPrefix${type.name}', currentLevel + 1);
    return true;
  }

  // -------------------------------------------------------------------
  // تصفير كامل (لأغراض "بدء جديد")
  // -------------------------------------------------------------------

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
          (k) =>
              k == _unlockedLevelKey ||
              k.startsWith(_highScorePrefix) ||
              k == _totalCoinsKey ||
              k == _totalGemsKey ||
              k.startsWith(_weaponLevelPrefix),
        );
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
