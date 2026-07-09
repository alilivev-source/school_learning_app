/// أنواع الأسلحة المتاحة للاعب. يمكن تبديلها أثناء اللعب بزر تغيير السلاح.
enum WeaponType { sword, bow, magic, bomb }

/// وصف بيانات كل سلاح (ضرر، سرعة مقذوف، مدة الشحن، إلخ).
class WeaponDef {
  final WeaponType type;
  final String iconAsset;
  final String? projectileAsset;
  final String soundAsset;
  final int damage;
  final double speed; // سرعة المقذوف (بكسل/ثانية) - غير مستخدمة للسيف
  final double cooldown; // زمن الانتظار بين كل هجومين بالثواني
  final double range; // مدى السيف (هجوم قريب) أو نصف قطر انفجار القنبلة
  final bool isMelee;

  const WeaponDef({
    required this.type,
    required this.iconAsset,
    required this.soundAsset,
    required this.damage,
    required this.cooldown,
    required this.range,
    this.projectileAsset,
    this.speed = 0,
    this.isMelee = false,
  });

  /// يرجع نسخة من هذا السلاح بإحصائيات مُحسّنة حسب مستوى الترقية من المتجر
  /// (1 = بدون ترقية، حتى SaveService.maxWeaponLevel). كل مستوى إضافي:
  /// - يرفع الضرر بمقدار 1.
  /// - يقلّل زمن الشحن (cooldown) قليلاً (سلاح أسرع).
  /// - يرفع مدى/سرعة السلاح قليلاً.
  WeaponDef upgraded(int level) {
    final extraLevels = (level - 1).clamp(0, 10);
    if (extraLevels == 0) return this;
    return WeaponDef(
      type: type,
      iconAsset: iconAsset,
      projectileAsset: projectileAsset,
      soundAsset: soundAsset,
      damage: damage + extraLevels,
      speed: speed > 0 ? speed + extraLevels * 18 : speed,
      cooldown: (cooldown - extraLevels * 0.04).clamp(0.12, cooldown),
      range: isMelee ? range + extraLevels * 4 : range,
      isMelee: isMelee,
    );
  }
}

/// قائمة كل الأسلحة الثابتة بالّلعبة، بالترتيب الذي يدور به زر تبديل السلاح.
class WeaponCatalog {
  static const sword = WeaponDef(
    type: WeaponType.sword,
    iconAsset: 'sprites/weapons/icon_sword.png',
    soundAsset: 'sword_swing.wav',
    damage: 2,
    cooldown: 0.35,
    range: 54,
    isMelee: true,
  );

  static const bow = WeaponDef(
    type: WeaponType.bow,
    iconAsset: 'sprites/weapons/icon_bow.png',
    projectileAsset: 'sprites/projectiles/arrow.png',
    soundAsset: 'bow_shoot.wav',
    damage: 1,
    speed: 340,
    cooldown: 0.45,
    range: 20,
  );

  static const magic = WeaponDef(
    type: WeaponType.magic,
    iconAsset: 'sprites/weapons/icon_magic.png',
    projectileAsset: 'sprites/projectiles/magic_bolt.png',
    soundAsset: 'magic_cast.wav',
    damage: 2,
    speed: 260,
    cooldown: 0.75,
    range: 20,
  );

  static const bomb = WeaponDef(
    type: WeaponType.bomb,
    iconAsset: 'sprites/weapons/icon_bomb.png',
    projectileAsset: 'sprites/projectiles/bomb.png',
    soundAsset: 'bomb_throw.wav',
    damage: 3,
    speed: 180,
    cooldown: 1.1,
    range: 70, // نصف قطر الانفجار
  );

  static const List<WeaponDef> all = [sword, bow, magic, bomb];

  static WeaponDef next(WeaponType current) {
    final i = all.indexWhere((w) => w.type == current);
    return all[(i + 1) % all.length];
  }
}
