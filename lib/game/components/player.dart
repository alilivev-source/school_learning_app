import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'collectible.dart';
import 'enemy.dart';
import 'maze_wall.dart';

/// اتجاهات المحارب (تُستخدم لتحديد جهة إطلاق الأسلحة والصورة المعروضة)
enum FacingDirection { up, down, left, right }

/// مكوّن اللاعب/المحارب داخل المتاهة، يُعرض بصور حقيقية من assets/sprites/player/.
class Player extends SpriteComponent with CollisionCallbacks {
  int health;
  final int maxHealth;
  FacingDirection facing = FacingDirection.down;
  bool isInvincible = false;

  /// صور اللاعب حسب الحالة: down / left / right / attack / hurt
  final Map<String, Sprite> sprites;

  /// يُستدعى عند اصطدام اللاعب بوحش (لإنقاص الصحة وتشغيل تأثير الإصابة).
  void Function(Enemy enemy)? onEnemyContact;

  /// يُستدعى عند وصول اللاعب لبوابة الخروج (لإنهاء المرحلة).
  void Function()? onExitReached;

  double _invincibilityTimer = 0;
  static const double invincibilityDuration = 0.6;

  double _hurtVisualTimer = 0;
  double _attackVisualTimer = 0;

  Player({
    required int startHealth,
    required this.sprites,
    Vector2? position,
    Vector2? size,
  })  : health = startHealth,
        maxHealth = startHealth,
        super(
          sprite: sprites['down'],
          position: position,
          size: size ?? Vector2.all(44),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      onEnemyContact?.call(other);
    } else if (other is Collectible) {
      other.collect();
    } else if (other is LevelExit) {
      onExitReached?.call();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_invincibilityTimer > 0) {
      _invincibilityTimer -= dt;
      if (_invincibilityTimer <= 0) isInvincible = false;
    }

    if (_hurtVisualTimer > 0) {
      _hurtVisualTimer -= dt;
      if (_hurtVisualTimer <= 0) _refreshSprite();
    }

    if (_attackVisualTimer > 0) {
      _attackVisualTimer -= dt;
      if (_attackVisualTimer <= 0) _refreshSprite();
    }

    // وميض بصري بسيط أثناء فترة عدم القابلية للتأثر (اصطدام أخير)
    opacity = isInvincible ? (0.5 + 0.5 * (((_invincibilityTimer * 12).floor() % 2))) : 1.0;
  }

  void _refreshSprite() {
    switch (facing) {
      case FacingDirection.left:
        sprite = sprites['left'];
        break;
      case FacingDirection.right:
        sprite = sprites['right'];
        break;
      case FacingDirection.up:
      case FacingDirection.down:
        sprite = sprites['down'];
        break;
    }
  }

  /// يحرك اللاعب بمقدار [delta] ويحدّث اتجاهه واتجاه صورته إن كانت الحركة محسوسة.
  void move(Vector2 delta) {
    if (delta.length2 < 0.0001) return;
    position.add(delta);

    final previousFacing = facing;
    if (delta.x.abs() > delta.y.abs()) {
      facing = delta.x > 0 ? FacingDirection.right : FacingDirection.left;
    } else {
      facing = delta.y > 0 ? FacingDirection.down : FacingDirection.up;
    }

    if (facing != previousFacing && _hurtVisualTimer <= 0 && _attackVisualTimer <= 0) {
      _refreshSprite();
    }
  }

  /// يعرض لمحة سريعة من صورة "الهجوم" (يُستخدم عند تفعيل السيف).
  void playAttackFlash() {
    _attackVisualTimer = 0.15;
    sprite = sprites['attack'];
  }

  /// نقطة يمكن إطلاق سلاح منها أمام اللاعب مباشرة، حسب اتجاهه الحالي.
  Vector2 get muzzlePosition {
    switch (facing) {
      case FacingDirection.up:
        return position + Vector2(0, -size.y);
      case FacingDirection.down:
        return position + Vector2(0, size.y);
      case FacingDirection.left:
        return position + Vector2(-size.x, 0);
      case FacingDirection.right:
        return position + Vector2(size.x, 0);
    }
  }

  Vector2 get facingVector {
    switch (facing) {
      case FacingDirection.up:
        return Vector2(0, -1);
      case FacingDirection.down:
        return Vector2(0, 1);
      case FacingDirection.left:
        return Vector2(-1, 0);
      case FacingDirection.right:
        return Vector2(1, 0);
    }
  }

  void takeDamage(int amount) {
    if (isInvincible) return;
    health = (health - amount).clamp(0, maxHealth);
    isInvincible = true;
    _invincibilityTimer = invincibilityDuration;
    _hurtVisualTimer = 0.3;
    sprite = sprites['hurt'];
  }

  bool get isDead => health <= 0;
}
