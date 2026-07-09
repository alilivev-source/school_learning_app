import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Colors, FontWeight, Shadow, TextStyle;

/// نص يظهر لحظيًا ثم يرتفع ويتلاشى تدريجيًا - يُستخدم لعرض الضرر أو نقاط الـCombo
/// أو أي إشعار بصري سريع فوق اللاعب أو العدو مباشرة.
class FloatingText extends TextComponent {
  final double duration;
  final Color baseColor;
  final double fontSize;
  final Vector2 riseBy;

  double _elapsed = 0;

  FloatingText({
    required String text,
    required Vector2 position,
    this.baseColor = Colors.white,
    this.fontSize = 18,
    this.duration = 0.7,
    Vector2? riseBy,
  })  : riseBy = riseBy ?? Vector2(0, -40),
        super(
          text: text,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              color: baseColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final t = (_elapsed / duration).clamp(0.0, 1.0);

    position.setValues(
      position.x + riseBy.x * (dt / duration),
      position.y + riseBy.y * (dt / duration),
    );

    final fadedAlpha = ((1.0 - t) * 255).clamp(0, 255).toInt();
    textRenderer = TextPaint(
      style: TextStyle(
        color: baseColor.withAlpha(fadedAlpha),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black.withAlpha(fadedAlpha), blurRadius: 4)],
      ),
    );

    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}
