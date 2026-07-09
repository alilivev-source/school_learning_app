import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// جدار ثابت داخل المتاهة. اللاعب والوحوش يصطدمون به ولا يمكنهم عبوره.
class MazeWall extends SpriteComponent with CollisionCallbacks {
  MazeWall({required Sprite sprite, required Vector2 position, required Vector2 size})
      : super(sprite: sprite, position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}

/// بلاطة أرضية بسيطة (بصرية فقط، بدون تصادم).
class MazeFloor extends SpriteComponent {
  MazeFloor({required Sprite sprite, required Vector2 position, required Vector2 size})
      : super(sprite: sprite, position: position, size: size, anchor: Anchor.topLeft);
}

/// بوابة الخروج/الفوز بالمرحلة.
class LevelExit extends SpriteComponent with CollisionCallbacks {
  LevelExit({required Sprite sprite, required Vector2 position, required Vector2 size})
      : super(sprite: sprite, position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}
