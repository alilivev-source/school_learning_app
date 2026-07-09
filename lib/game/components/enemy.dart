import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../level_generator.dart';

/// دالة يوفرها المولّد الرئيسي للّعبة للتحقق هل نقطة عالمية (world position)
/// قابلة للمشي عليها (ليست جدارًا). تُستخدم لمنع الوحش من عبور الجدران.
typedef WalkableChecker = bool Function(Vector2 worldPosition);

/// مكوّن الوحش (Enemy) داخل المتاهة، يُعرض بصورة حقيقية من assets/sprites/enemies/.
class Enemy extends SpriteComponent with CollisionCallbacks {
  int health;
  final double speed;
  final EnemyBehavior behavior;
  final int contactDamage;
  final bool isBoss;
  final Vector2 Function() playerPositionProvider;
  final WalkableChecker isWalkable;

  /// يُستدعى عند موت الوحش (لعرض تأثير موت وتشغيل صوت وإضافة نقاط).
  void Function(Enemy enemy)? onDeath;

  /// يُستدعى عند نقصان صحة الوحش (يُستخدم لتحديث شريط صحة الزعيم بالواجهة).
  void Function(Enemy enemy)? onDamaged;

  final Random _rng = Random();
  Vector2 _wanderDirection = Vector2.zero();
  double _wanderTimer = 0;

  bool _dead = false;
  bool get isDead => health <= 0;

  Enemy({
    required int startHealth,
    required this.speed,
    required this.behavior,
    required this.playerPositionProvider,
    required this.isWalkable,
    required Sprite sprite,
    required this.contactDamage,
    this.isBoss = false,
    Vector2? position,
    Vector2? size,
  })  : health = startHealth,
        super(
          sprite: sprite,
          position: position,
          size: size ?? Vector2.all(isBoss ? 62 : 38),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.active);
    _pickNewWanderDirection();
  }

  void _pickNewWanderDirection() {
    final angle = _rng.nextDouble() * 2 * pi;
    _wanderDirection = Vector2(cos(angle), sin(angle));
    _wanderTimer = 1 + _rng.nextDouble() * 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    Vector2 direction;
    if (behavior == EnemyBehavior.chase) {
      final toPlayer = playerPositionProvider() - position;
      direction = toPlayer.length2 > 0.01 ? toPlayer.normalized() : Vector2.zero();
    } else {
      _wanderTimer -= dt;
      if (_wanderTimer <= 0) _pickNewWanderDirection();
      direction = _wanderDirection;
    }

    final movement = direction * speed * dt;
    final nextPosition = position + movement;

    final nextX = Vector2(nextPosition.x, position.y);
    final nextY = Vector2(position.x, nextPosition.y);

    if (isWalkable(nextX)) position.x = nextX.x;
    if (isWalkable(nextY)) position.y = nextY.y;
  }

  /// ينقص صحة الوحش، ويُعلّم للحذف إذا وصلت للصفر.
  void takeDamage(int amount) {
    if (_dead) return;
    health -= amount;
    if (health <= 0) {
      _dead = true;
      onDeath?.call(this);
      removeFromParent();
    } else {
      onDamaged?.call(this);
    }
  }
}
