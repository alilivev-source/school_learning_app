import 'dart:math';

/// نوع الخانة داخل شبكة المتاهة
enum TileType { wall, floor, exit }

/// سلوك حركة الوحش
enum EnemyBehavior { chase, wander }

/// نوع الجائزة القابلة للالتقاط (بدون اعتماد على Flame حتى يبقى هذا الملف
/// قابلاً للاختبار بمنطق بحت؛ يتم تحويلها لمكوّن Collectible داخل DungeonGame).
enum CollectibleKind { coin, gem, heart, key, chest }

class CollectibleSpawn {
  final int row;
  final int col;
  final CollectibleKind kind;

  const CollectibleSpawn({required this.row, required this.col, required this.kind});
}

/// بيانات ولادة وحش واحد داخل المرحلة
class EnemySpawn {
  final int row;
  final int col;
  final EnemyBehavior behavior;
  final int health;
  final double speed;
  final int contactDamage;
  final bool isBoss;

  const EnemySpawn({
    required this.row,
    required this.col,
    required this.behavior,
    required this.health,
    required this.speed,
    required this.contactDamage,
    this.isBoss = false,
  });
}

/// كل البيانات اللازمة لبناء مرحلة واحدة داخل اللعبة
class LevelData {
  final int levelNumber;
  final int rows;
  final int cols;
  final List<List<TileType>> grid;
  final int startRow;
  final int startCol;
  final int exitRow;
  final int exitCol;
  final List<EnemySpawn> enemies;
  final List<CollectibleSpawn> collectibles;
  final int playerHealth;
  final double tileSize;
  final bool isBossLevel;

  const LevelData({
    required this.levelNumber,
    required this.rows,
    required this.cols,
    required this.grid,
    required this.startRow,
    required this.startCol,
    required this.exitRow,
    required this.exitCol,
    required this.enemies,
    required this.collectibles,
    required this.playerHealth,
    required this.isBossLevel,
    this.tileSize = 48,
  });
}

/// يبني المتاهة والوحوش لأي مرحلة من 1 إلى 100 بشكل إجرائي (procedural).
///
/// بدل إنشاء 100 ملف Dart يدوي (غير عملي للصيانة)، نستخدم بذرة عشوائية
/// ثابتة لكل رقم مرحلة (seed = levelNumber) حتى تكون نفس المرحلة ثابتة
/// الشكل في كل مرة يلعبها نفس المستخدم، لكن مختلفة عن باقي المراحل.
class LevelGenerator {
  static const int maxLevel = 100;

  static LevelData generate(int levelNumber) {
    assert(levelNumber >= 1 && levelNumber <= maxLevel);

    final rng = Random(levelNumber * 7919); // بذرة ثابتة لكل مرحلة

    final sizeStep = (levelNumber / 10).floor(); // 0..9
    final cells = 5 + sizeStep; // عدد خلايا المتاهة (5..14)
    final rows = cells * 2 + 1;
    final cols = cells * 2 + 1;

    final grid = _generateMaze(rows, cols, rng);

    const startRow = 1, startCol = 1;
    final exitRow = rows - 2;
    final exitCol = cols - 2;
    grid[exitRow][exitCol] = TileType.exit;

    final enemies = _generateEnemies(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      grid: grid,
      startRow: startRow,
      startCol: startCol,
      rng: rng,
    );

    final collectibles = _generateCollectibles(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      grid: grid,
      startRow: startRow,
      startCol: startCol,
      rng: rng,
    );

    final playerHealth = max(6, 12 - (levelNumber / 20).floor());

    return LevelData(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      grid: grid,
      startRow: startRow,
      startCol: startCol,
      exitRow: exitRow,
      exitCol: exitCol,
      enemies: enemies,
      collectibles: collectibles,
      playerHealth: playerHealth,
      isBossLevel: levelNumber % 10 == 0,
    );
  }

  /// خوارزمية Recursive Backtracker الكلاسيكية لتوليد متاهة مثالية
  static List<List<TileType>> _generateMaze(int rows, int cols, Random rng) {
    final grid = List.generate(rows, (_) => List.filled(cols, TileType.wall));

    void carve(int r, int c) {
      grid[r][c] = TileType.floor;
      final directions = [
        [-2, 0],
        [2, 0],
        [0, -2],
        [0, 2],
      ]..shuffle(rng);

      for (final d in directions) {
        final nr = r + d[0];
        final nc = c + d[1];
        if (nr > 0 && nr < rows - 1 && nc > 0 && nc < cols - 1 && grid[nr][nc] == TileType.wall) {
          grid[r + d[0] ~/ 2][c + d[1] ~/ 2] = TileType.floor;
          carve(nr, nc);
        }
      }
    }

    carve(1, 1);

    final extraOpenings = (rows * cols / 40).floor();
    for (var i = 0; i < extraOpenings; i++) {
      final r = 1 + rng.nextInt(rows - 2);
      final c = 1 + rng.nextInt(cols - 2);
      if (r % 2 == 0 || c % 2 == 0) {
        grid[r][c] = TileType.floor;
      }
    }

    return grid;
  }

  static List<EnemySpawn> _generateEnemies({
    required int levelNumber,
    required int rows,
    required int cols,
    required List<List<TileType>> grid,
    required int startRow,
    required int startCol,
    required Random rng,
  }) {
    final isBossLevel = levelNumber % 10 == 0;

    // عدد الوحوش العاديين يزيد كل 5 مراحل؛ في مراحل الزعيم نقلّلهم قليلاً
    // (نصف العدد تقريبًا) حتى يبرز الزعيم كمركز التحدي بدل الازدحام.
    final baseCount = min(2 + (levelNumber / 5).floor(), 18);
    final enemyCount = isBossLevel ? (baseCount / 2).ceil() : baseCount;

    final chaseRatio = min(0.2 + levelNumber * 0.007, 0.9);
    final enemyHealth = 2 + (levelNumber / 8).floor();
    final enemySpeed = 40.0 + (levelNumber * 0.8);

    // ضرر التلامس يتصاعد مع صعوبة المرحلة بدل ما يكون ثابتًا لكل الوحوش
    final baseContactDamage = 1 + (levelNumber / 25).floor();

    final floorCells = <List<int>>[];
    for (var r = 1; r < rows - 1; r++) {
      for (var c = 1; c < cols - 1; c++) {
        if (grid[r][c] == TileType.floor) {
          final distFromStart = (r - startRow).abs() + (c - startCol).abs();
          if (distFromStart > 3) {
            floorCells.add([r, c]);
          }
        }
      }
    }
    floorCells.shuffle(rng);

    final spawns = <EnemySpawn>[];
    var cellIndex = 0;

    if (isBossLevel && floorCells.isNotEmpty) {
      // الزعيم يظهر في أبعد نقطة ممكنة عن اللاعب لإعطاء شعور "مواجهة نهاية المرحلة"
      floorCells.sort((a, b) {
        final da = (a[0] - startRow).abs() + (a[1] - startCol).abs();
        final db = (b[0] - startRow).abs() + (b[1] - startCol).abs();
        return db.compareTo(da);
      });
      final bossCell = floorCells.removeAt(0);
      spawns.add(EnemySpawn(
        row: bossCell[0],
        col: bossCell[1],
        behavior: EnemyBehavior.chase,
        health: enemyHealth * 6,
        speed: enemySpeed * 0.75,
        contactDamage: baseContactDamage * 2,
        isBoss: true,
      ));
      floorCells.shuffle(rng);
    }

    final count = min(enemyCount, floorCells.length);
    for (var i = 0; i < count; i++) {
      final cell = floorCells[cellIndex++];
      final behavior = rng.nextDouble() < chaseRatio ? EnemyBehavior.chase : EnemyBehavior.wander;
      spawns.add(EnemySpawn(
        row: cell[0],
        col: cell[1],
        behavior: behavior,
        health: enemyHealth,
        speed: enemySpeed,
        contactDamage: baseContactDamage,
      ));
    }

    return spawns;
  }

  static List<CollectibleSpawn> _generateCollectibles({
    required int levelNumber,
    required int rows,
    required int cols,
    required List<List<TileType>> grid,
    required int startRow,
    required int startCol,
    required Random rng,
  }) {
    final floorCells = <List<int>>[];
    for (var r = 1; r < rows - 1; r++) {
      for (var c = 1; c < cols - 1; c++) {
        if (grid[r][c] == TileType.floor) {
          final distFromStart = (r - startRow).abs() + (c - startCol).abs();
          if (distFromStart > 1) {
            floorCells.add([r, c]);
          }
        }
      }
    }
    floorCells.shuffle(rng);

    final spawns = <CollectibleSpawn>[];
    var index = 0;

    int take() => index < floorCells.length ? index++ : -1;

    // عملات: تزيد قليلًا مع المراحل، بحد أقصى معقول حتى لا تزدحم المتاهة
    final coinCount = min(4 + (levelNumber / 4).floor(), 12);
    for (var i = 0; i < coinCount; i++) {
      final idx = take();
      if (idx == -1) break;
      spawns.add(CollectibleSpawn(row: floorCells[idx][0], col: floorCells[idx][1], kind: CollectibleKind.coin));
    }

    // جواهر: نادرة، قيمة أعلى
    final gemCount = 1 + (levelNumber / 15).floor();
    for (var i = 0; i < gemCount; i++) {
      final idx = take();
      if (idx == -1) break;
      spawns.add(CollectibleSpawn(row: floorCells[idx][0], col: floorCells[idx][1], kind: CollectibleKind.gem));
    }

    // قلب صحة إضافي كل بضع مراحل لموازنة صعوبة الأعداء المتصاعدة
    if (levelNumber % 3 == 0) {
      final idx = take();
      if (idx != -1) {
        spawns.add(CollectibleSpawn(row: floorCells[idx][0], col: floorCells[idx][1], kind: CollectibleKind.heart));
      }
    }

    // مفتاح + صندوق كنز كل 5 مراحل كمكافأة إضافية اختيارية
    if (levelNumber % 5 == 0) {
      final keyIdx = take();
      final chestIdx = take();
      if (keyIdx != -1) {
        spawns.add(CollectibleSpawn(row: floorCells[keyIdx][0], col: floorCells[keyIdx][1], kind: CollectibleKind.key));
      }
      if (chestIdx != -1) {
        spawns.add(
            CollectibleSpawn(row: floorCells[chestIdx][0], col: floorCells[chestIdx][1], kind: CollectibleKind.chest));
      }
    }

    return spawns;
  }
}
