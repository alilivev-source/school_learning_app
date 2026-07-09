import 'dart:math' show atan2;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'enemy.dart';
import 'maze_wall.dart';

/// دالة تُستدعى عند إصابة أو انفجار المقذوف، لعرض تأثير بصري وتشغيل صوت.
typedef ProjectileHitCallback = void Function(Vector2 worldPosition);

/// دالة تُستدعى لإلحاق ضرر بكل الأعداء ضمن دائرة حول نقطة معينة (لانفجار القنبلة).
typedef SplashDamageCallback = void Function(Vector2 center, double radius, int damage);

/// مقذوف يتحرك باتجاه واحد ويصطدم بالأعداء أو الجدران.
class Projectile extends SpriteComponent with CollisionCallbacks {
  final Vector2 direction;
  final double speed;
  final int damage;
  final bool isBomb;
  final double splashRadius;
  final ProjectileHitCallback onHitEffect;
  final SplashDamageCallback onSplashDamage;

  double _lifeTime = 3; // إزالة تلقائية بعد 3 ثوانٍ لتفادي تسرب الذاكرة

  Projectile({
    required Sprite sprite,
    required Vector2 position,
    required this.direction,
    required this.speed,
    required this.damage,
    required this.onHitEffect,
    required this.onSplashDamage,
    this.isBomb = false,
    this.splashRadius = 0,
    Vector2? size,
  }) : super(
          sprite: sprite,
          position: position,
          size: size ?? Vector2.all(20),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.active);
    angle = atan2(direction.y, direction.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(direction * speed * dt);
    _lifeTime -= dt;
    if (_lifeTime <= 0) {
      _explode();
    }
  }

  void _explode() {
    if (!isMounted) return;
    onHitEffect(position.clone());
    if (isBomb) {
      onSplashDamage(position.clone(), splashRadius, damage);
    }
    removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      if (isBomb) {
        _explode();
      } else {
        other.takeDamage(damage);
        onHitEffect(position.clone());
        removeFromParent();
      }
    } else if (other is MazeWall) {
      _explode();
    }
  }
}
