import 'package:flame/components.dart';

/// تأثير بصري قصير العمر (صورة تظهر ثم تختفي تلقائيًا بعد [duration]).
/// يُستخدم لكل شيء بصري مؤقت: شرارة اصطدام، انفجار، ضربة سيف، غبار الانزلاق.
class EffectSprite extends SpriteComponent {
  final double duration;
  double _elapsed = 0;
  final double growTo;

  EffectSprite({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    this.duration = 0.35,
    this.growTo = 1.3,
    double angle = 0,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
          anchor: Anchor.center,
          angle: angle,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    scale.setAll(1.0 + (growTo - 1.0) * t);
    opacity = 1.0 - t;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}
