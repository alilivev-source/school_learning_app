import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// أنواع العناصر القابلة للالتقاط داخل المتاهة.
enum CollectibleType { coin, gem, heart, key, chest }

/// دالة تُستدعى عند التقاط اللاعب لعنصر ما.
typedef CollectCallback = void Function(CollectibleType type);

/// عملة / جوهرة / قلب صحة / مفتاح / صندوق كنز - كلها تُمثَّل بنفس المكوّن
/// مع اختلاف الصورة والتأثير عند الالتقاط.
class Collectible extends SpriteComponent with CollisionCallbacks {
  final CollectibleType type;
  final CollectCallback onCollect;
  bool _collected = false;

  Collectible({
    required Sprite sprite,
    required this.type,
    required this.onCollect,
    required Vector2 position,
    Vector2? size,
  }) : super(
          sprite: sprite,
          position: position,
          size: size ?? Vector2.all(28),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  void collect() {
    if (_collected) return;
    _collected = true;
    onCollect(type);
    removeFromParent();
  }
}
