import 'dart:math';
import 'dart:ui' show Color;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import 'components/collectible.dart';
import 'components/effect_sprite.dart';
import 'components/enemy.dart';
import 'components/floating_text.dart';
import 'components/maze_wall.dart';
import 'components/player.dart';
import 'components/projectile.dart';
import 'game_status.dart';
import 'level_generator.dart';
import 'weapons.dart';
import '../services/save_service.dart';

/// محرك اللعبة الرئيسي المبني على Flame. يدير تحميل المراحل، حركة اللاعب
/// والأعداء (بما فيهم الزعماء كل 10 مراحل)، إطلاق الأسلحة القابلة للترقية،
/// الجوائز، نظام الـ Combo، اهتزاز الشاشة، والانتقال المتحرك بين مرحلة وأخرى.
class DungeonGame extends FlameGame with HasCollisionDetection {
  final int startLevel;
  DungeonGame({this.startLevel = 1});

  static const double moveSpeed = 170;
  static const double tileSize = 48;

  late Player player;
  LevelData? currentLevel;

  // ---- ذاكرة الصور المُحمّلة مسبقًا ----
  late Map<String, Sprite> _playerSprites;
  late Sprite _wallSprite;
  late Sprite _floorSprite;
  late Sprite _exitSprite;
  late Sprite _enemyChaserSprite;
  late Sprite _enemyWandererSprite;
  late Sprite _enemyEliteSprite;
  late Sprite _hitSparkSprite;
  late Sprite _explosionSprite;
  late Sprite _slashSprite;
  late Sprite _portalSprite;
  late Sprite _dustSprite;
  late Map<WeaponType, Sprite> _projectileSprites;
  late Map<CollectibleKind, Sprite> _collectibleSprites;

  // ---- مستويات ترقية الأسلحة (من المتجر) ----
  Map<WeaponType, int> _weaponLevels = {for (final t in WeaponType.values) t: 1};

  // ---- حالة اللعبة المكشوفة للواجهة (Flutter overlays) ----
  final ValueNotifier<int> healthNotifier = ValueNotifier(10);
  final ValueNotifier<int> maxHealthNotifier = ValueNotifier(10);
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> gemsNotifier = ValueNotifier(0);
  final ValueNotifier<bool> hasKeyNotifier = ValueNotifier(false);
  final ValueNotifier<WeaponType> weaponNotifier = ValueNotifier(WeaponType.sword);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);
  final ValueNotifier<GameStatus> statusNotifier = ValueNotifier(GameStatus.playing);
  final ValueNotifier<bool> soundEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<bool> musicEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<int> comboNotifier = ValueNotifier(0);
  final ValueNotifier<bool> isBossLevelNotifier = ValueNotifier(false);
  final ValueNotifier<bool> bossAliveNotifier = ValueNotifier(false);
  final ValueNotifier<int> bossHealthNotifier = ValueNotifier(0);
  final ValueNotifier<int> bossMaxHealthNotifier = ValueNotifier(0);

  /// اتجاه الحركة الحالي القادم من عصا التحكم (Joystick) في الواجهة.
  Vector2 joystickDirection = Vector2.zero();

  final List<Component> _levelComponents = [];

  double _weaponCooldownTimer = 0;
  double _jumpCooldownTimer = 0;
  double _slideCooldownTimer = 0;
  double? _jumpTimer;
  double? _slideTimer;
  Vector2? _slideDirection;
  static const double _slideSpeed = 520;
  static const double _slideDuration = 0.22;

  double? _transitionElapsed;
  Vector2? _transitionStart;
  Vector2? _transitionTarget;
  static const double _transitionMoveDuration = 0.45;
  static const double _transitionShrinkDuration = 0.55;

  // ---- Combo: قتل أعداء متتاليين خلال نافذة زمنية قصيرة يرفع مكافأة النقاط ----
  double _comboTimer = 0;
  static const double _comboWindow = 2.5;

  // ---- اهتزاز الشاشة (Screen Shake) ----
  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  final Random _rng = Random();

  @override
  Color backgroundColor() => const Color(0xFF120E1A);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _preloadAssets();
    await _loadPersistentState();

    player = Player(
      startHealth: 10,
      sprites: _playerSprites,
      position: Vector2.zero(),
    );
    player.onEnemyContact = _handlePlayerEnemyContact;
    player.onExitReached = _handlePlayerReachedExit;

    world.add(player);
    camera.follow(player);

    if (musicEnabledNotifier.value) {
      _playMusic();
    }

    await loadLevel(startLevel);
  }

  Future<void> _preloadAssets() async {
    Future<Sprite> s(String path) => loadSprite(path);

    _playerSprites = {
      'down': await s('sprites/player/player_down.png'),
      'left': await s('sprites/player/player_left.png'),
      'right': await s('sprites/player/player_right.png'),
      'attack': await s('sprites/player/player_attack.png'),
      'hurt': await s('sprites/player/player_hurt.png'),
    };

    _wallSprite = await s('sprites/obstacles/wall.png');
    _floorSprite = await s('sprites/obstacles/floor.png');
    _exitSprite = await s('sprites/effects/portal.png');

    _enemyChaserSprite = await s('sprites/enemies/enemy_chaser.png');
    _enemyWandererSprite = await s('sprites/enemies/enemy_wanderer.png');
    _enemyEliteSprite = await s('sprites/enemies/enemy_elite.png');

    _hitSparkSprite = await s('sprites/effects/hit_spark.png');
    _explosionSprite = await s('sprites/effects/explosion.png');
    _slashSprite = await s('sprites/effects/slash.png');
    _portalSprite = await s('sprites/effects/portal.png');
    _dustSprite = await s('sprites/effects/dust.png');

    _projectileSprites = {
      WeaponType.bow: await s('sprites/projectiles/arrow.png'),
      WeaponType.magic: await s('sprites/projectiles/magic_bolt.png'),
      WeaponType.bomb: await s('sprites/projectiles/bomb.png'),
    };

    _collectibleSprites = {
      CollectibleKind.coin: await s('sprites/items/coin.png'),
      CollectibleKind.gem: await s('sprites/items/gem.png'),
      CollectibleKind.heart: await s('sprites/items/heart.png'),
      CollectibleKind.key: await s('sprites/items/key.png'),
      CollectibleKind.chest: await s('sprites/items/chest_closed.png'),
    };
  }

  Future<void> _loadPersistentState() async {
    soundEnabledNotifier.value = await SaveService.isSoundEnabled();
    musicEnabledNotifier.value = await SaveService.isMusicEnabled();
    _weaponLevels = await SaveService.getAllWeaponLevels();
    coinsNotifier.value = await SaveService.getTotalCoins();
    gemsNotifier.value = await SaveService.getTotalGems();
  }

  // ---------------------------------------------------------------------
  // تحميل/بناء المرحلة
  // ---------------------------------------------------------------------

  Future<void> loadLevel(int levelNumber) async {
    for (final c in _levelComponents) {
      c.removeFromParent();
    }
    _levelComponents.clear();

    final level = LevelGenerator.generate(levelNumber);
    currentLevel = level;
    isBossLevelNotifier.value = level.isBossLevel;
    bossAliveNotifier.value = level.isBossLevel;

    for (var r = 0; r < level.rows; r++) {
      for (var c = 0; c < level.cols; c++) {
        final pos = Vector2(c * tileSize, r * tileSize);
        if (level.grid[r][c] == TileType.wall) {
          final wall = MazeWall(sprite: _wallSprite, position: pos, size: Vector2.all(tileSize));
          world.add(wall);
          _levelComponents.add(wall);
        } else {
          final floor = MazeFloor(sprite: _floorSprite, position: pos, size: Vector2.all(tileSize));
          world.add(floor);
          _levelComponents.add(floor);
          if (level.grid[r][c] == TileType.exit) {
            final exit = LevelExit(sprite: _exitSprite, position: pos, size: Vector2.all(tileSize));
            world.add(exit);
            _levelComponents.add(exit);
          }
        }
      }
    }

    for (final spawn in level.enemies) {
      final sprite = spawn.isBoss
          ? _enemyEliteSprite
          : (spawn.behavior == EnemyBehavior.chase ? _enemyChaserSprite : _enemyWandererSprite);
      final enemy = Enemy(
        startHealth: spawn.health,
        speed: spawn.speed,
        behavior: spawn.behavior,
        sprite: sprite,
        contactDamage: spawn.contactDamage,
        isBoss: spawn.isBoss,
        playerPositionProvider: () => player.position,
        isWalkable: _isWalkable,
        position: _tileCenter(spawn.row, spawn.col),
      );
      enemy.onDeath = _handleEnemyDeath;
      if (spawn.isBoss) {
        enemy.onDamaged = (e) => bossHealthNotifier.value = e.health;
        bossHealthNotifier.value = spawn.health;
        bossMaxHealthNotifier.value = spawn.health;
      }
      world.add(enemy);
      _levelComponents.add(enemy);
    }

    for (final spawn in level.collectibles) {
      final sprite = _collectibleSprites[spawn.kind]!;
      final collectible = Collectible(
        sprite: sprite,
        type: _mapCollectibleType(spawn.kind),
        onCollect: _handleCollect,
        position: _tileCenter(spawn.row, spawn.col),
      );
      world.add(collectible);
      _levelComponents.add(collectible);
    }

    player.position = _tileCenter(level.startRow, level.startCol);
    player.scale.setAll(1.0);
    player.angle = 0;
    player.opacity = 1.0;
    if (levelNumber == startLevel) {
      player.health = level.playerHealth;
    } else {
      player.health = min(player.health + 2, level.playerHealth);
    }

    healthNotifier.value = player.health;
    maxHealthNotifier.value = level.playerHealth;
    levelNotifier.value = levelNumber;
    statusNotifier.value = GameStatus.playing;
    hasKeyNotifier.value = false;
    comboNotifier.value = 0;
    _comboTimer = 0;
  }

  CollectibleType _mapCollectibleType(CollectibleKind kind) {
    switch (kind) {
      case CollectibleKind.coin:
        return CollectibleType.coin;
      case CollectibleKind.gem:
        return CollectibleType.gem;
      case CollectibleKind.heart:
        return CollectibleType.heart;
      case CollectibleKind.key:
        return CollectibleType.key;
      case CollectibleKind.chest:
        return CollectibleType.chest;
    }
  }

  Vector2 _tileCenter(int row, int col) {
    return Vector2((col + 0.5) * tileSize, (row + 0.5) * tileSize);
  }

  bool _isWalkable(Vector2 worldPosition) {
    final level = currentLevel;
    if (level == null) return false;
    final col = (worldPosition.x / tileSize).floor();
    final row = (worldPosition.y / tileSize).floor();
    if (row < 0 || row >= level.rows || col < 0 || col >= level.cols) return false;
    return level.grid[row][col] != TileType.wall;
  }

  // ---------------------------------------------------------------------
  // حلقة التحديث الرئيسية
  // ---------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);

    _updateShake(dt);

    if (statusNotifier.value == GameStatus.transitioning) {
      _updateTransition(dt);
      return;
    }

    if (statusNotifier.value != GameStatus.playing) return;

    _updateCooldowns(dt);
    _updateCombo(dt);
    _updatePlayerMovement(dt);
    _updateSlide(dt);
    _updateJumpVisual(dt);
  }

  void _updateCooldowns(double dt) {
    if (_weaponCooldownTimer > 0) _weaponCooldownTimer -= dt;
    if (_jumpCooldownTimer > 0) _jumpCooldownTimer -= dt;
    if (_slideCooldownTimer > 0) _slideCooldownTimer -= dt;
  }

  void _updateCombo(double dt) {
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        comboNotifier.value = 0;
      }
    }
  }

  void _updateShake(double dt) {
    if (_shakeTimer <= 0) return;
    _shakeTimer -= dt;
    final dx = (_rng.nextDouble() * 2 - 1) * _shakeIntensity;
    final dy = (_rng.nextDouble() * 2 - 1) * _shakeIntensity;
    camera.viewfinder.position += Vector2(dx, dy);
    if (_shakeTimer <= 0) _shakeIntensity = 0;
  }

  void _triggerShake(double intensity, double duration) {
    _shakeIntensity = intensity;
    _shakeTimer = duration;
  }

  void _updatePlayerMovement(double dt) {
    if (_slideTimer != null) return;
    if (joystickDirection.length2 < 0.0001) return;

    final delta = joystickDirection.normalized() * moveSpeed * dt;
    final next = player.position + delta;

    final nextX = Vector2(next.x, player.position.y);
    final nextY = Vector2(player.position.x, next.y);

    final moveVector = Vector2.zero();
    if (_isWalkable(nextX)) moveVector.x = delta.x;
    if (_isWalkable(nextY)) moveVector.y = delta.y;

    player.move(moveVector);
  }

  void _updateSlide(double dt) {
    if (_slideTimer == null) return;
    _slideTimer = _slideTimer! + dt;
    if (_slideTimer! <= _slideDuration) {
      final move = _slideDirection! * _slideSpeed * dt;
      final next = player.position + move;
      if (_isWalkable(next)) {
        player.position = next;
      } else {
        _slideTimer = null;
        player.isInvincible = false;
      }
    } else {
      _slideTimer = null;
      player.isInvincible = false;
    }
  }

  void _updateJumpVisual(double dt) {
    if (_jumpTimer == null) return;
    _jumpTimer = _jumpTimer! + dt;
    const jumpDuration = 0.32;
    final t = (_jumpTimer! / jumpDuration).clamp(0.0, 1.0);
    final bounce = sin(t * pi);
    player.scale.setAll(1.0 + bounce * 0.28);
    if (t >= 1.0) {
      _jumpTimer = null;
      player.scale.setAll(1.0);
      player.isInvincible = false;
    }
  }

  // ---------------------------------------------------------------------
  // تحكم اللاعب من الواجهة (تُستدعى من أزرار HUD)
  // ---------------------------------------------------------------------

  void setJoystickDirection(Vector2 direction) {
    joystickDirection = direction;
  }

  WeaponDef get _currentWeapon {
    final base = WeaponCatalog.all.firstWhere((w) => w.type == weaponNotifier.value);
    final level = _weaponLevels[weaponNotifier.value] ?? 1;
    return base.upgraded(level);
  }

  void fireWeapon() {
    if (statusNotifier.value != GameStatus.playing) return;
    if (_weaponCooldownTimer > 0) return;

    final weapon = _currentWeapon;
    _weaponCooldownTimer = weapon.cooldown;

    _playSound(weapon.soundAsset);

    if (weapon.isMelee) {
      _performMeleeAttack(weapon);
    } else {
      _spawnProjectile(weapon);
    }
  }

  void _performMeleeAttack(WeaponDef weapon) {
    player.playAttackFlash();

    final origin = player.muzzlePosition;
    _spawnEffect(_slashSprite, origin, size: 60, duration: 0.2);

    final facing = player.facingVector;
    for (final component in world.children.toList()) {
      if (component is Enemy && !component.isDead) {
        final toEnemy = component.position - player.position;
        final distance = toEnemy.length;
        if (distance <= weapon.range) {
          final dot = distance > 0 ? (toEnemy.normalized().dot(facing)) : 1.0;
          if (dot > 0.3) {
            component.takeDamage(weapon.damage);
            _spawnEffect(_hitSparkSprite, component.position, size: 40, duration: 0.25);
          }
        }
      }
    }
  }

  void _spawnProjectile(WeaponDef weapon) {
    final sprite = _projectileSprites[weapon.type]!;
    final projectile = Projectile(
      sprite: sprite,
      position: player.muzzlePosition,
      direction: player.facingVector,
      speed: weapon.speed,
      damage: weapon.damage,
      isBomb: weapon.type == WeaponType.bomb,
      splashRadius: weapon.range,
      size: Vector2.all(weapon.type == WeaponType.bomb ? 26 : 20),
      onHitEffect: (pos) {
        final fxSprite = weapon.type == WeaponType.bomb ? _explosionSprite : _hitSparkSprite;
        _spawnEffect(fxSprite, pos, size: weapon.type == WeaponType.bomb ? 130 : 40, duration: 0.3);
        if (weapon.type == WeaponType.bomb) {
          _playSound('explosion.wav');
          _triggerShake(6, 0.25);
          HapticFeedback.mediumImpact();
        }
      },
      onSplashDamage: _applySplashDamage,
    );
    world.add(projectile);
  }

  void _applySplashDamage(Vector2 center, double radius, int damage) {
    for (final component in world.children.toList()) {
      if (component is Enemy && !component.isDead) {
        if ((component.position - center).length <= radius) {
          component.takeDamage(damage);
        }
      }
    }
  }

  void switchWeapon() {
    if (statusNotifier.value != GameStatus.playing) return;
    weaponNotifier.value = WeaponCatalog.next(weaponNotifier.value).type;
    _playSound('weapon_switch.wav');
  }

  void jump() {
    if (statusNotifier.value != GameStatus.playing) return;
    if (_jumpCooldownTimer > 0) return;
    _jumpCooldownTimer = 0.6;
    _jumpTimer = 0;
    player.isInvincible = true;
    _playSound('jump.wav');
  }

  void slide() {
    if (statusNotifier.value != GameStatus.playing) return;
    if (_slideCooldownTimer > 0) return;
    _slideCooldownTimer = 1.0;
    _slideTimer = 0;
    _slideDirection = player.facingVector.clone();
    player.isInvincible = true;
    _playSound('slide.wav');
    _spawnEffect(_dustSprite, player.position.clone(), size: 50, duration: 0.4);
  }

  void togglePause() {
    if (statusNotifier.value == GameStatus.playing) {
      statusNotifier.value = GameStatus.paused;
      pauseEngine();
    } else if (statusNotifier.value == GameStatus.paused) {
      statusNotifier.value = GameStatus.playing;
      resumeEngine();
    }
  }

  // ---------------------------------------------------------------------
  // ردود أفعال الأحداث (اصطدام، موت، جمع، خروج)
  // ---------------------------------------------------------------------

  void _handlePlayerEnemyContact(Enemy enemy) {
    if (player.isInvincible) return;
    player.takeDamage(enemy.contactDamage);
    healthNotifier.value = player.health;
    _spawnEffect(_hitSparkSprite, player.position.clone(), size: 45, duration: 0.3);
    _playSound('player_hurt.wav');
    _triggerShake(enemy.isBoss ? 8 : 4, 0.2);
    HapticFeedback.mediumImpact();

    // الاصطدام بعدو يكسر سلسلة الـ Combo الحالية
    comboNotifier.value = 0;
    _comboTimer = 0;

    if (player.isDead) {
      _handleGameOver();
    }
  }

  void _handleEnemyDeath(Enemy enemy) {
    final fxSize = enemy.isBoss ? 150.0 : 70.0;
    _spawnEffect(_explosionSprite, enemy.position.clone(), size: fxSize, duration: enemy.isBoss ? 0.6 : 0.35);
    _playSound('enemy_die.wav');
    HapticFeedback.lightImpact();

    comboNotifier.value += 1;
    _comboTimer = _comboWindow;
    final comboBonus = (comboNotifier.value - 1) * 5;

    if (enemy.isBoss) {
      bossAliveNotifier.value = false;
      final bossScore = 200 + comboBonus;
      scoreNotifier.value += bossScore;
      _triggerShake(10, 0.4);
      HapticFeedback.heavyImpact();
      world.add(FloatingText(
        text: 'الزعيم هُزم! +$bossScore',
        position: enemy.position.clone(),
        baseColor: const Color(0xFFFFD700),
        fontSize: 22,
        duration: 1.2,
      ));
    } else {
      final points = 10 + comboBonus;
      scoreNotifier.value += points;
      if (comboNotifier.value >= 2) {
        world.add(FloatingText(
          text: 'Combo x${comboNotifier.value}  +$points',
          position: enemy.position.clone(),
          baseColor: const Color(0xFF7CFFB2),
          fontSize: 16,
        ));
      }
    }
  }

  void _handleCollect(CollectibleType type) {
    switch (type) {
      case CollectibleType.coin:
        coinsNotifier.value += 1;
        scoreNotifier.value += 5;
        SaveService.addCoins(1);
        _playSound('coin_pickup.wav');
        break;
      case CollectibleType.gem:
        gemsNotifier.value += 1;
        scoreNotifier.value += 25;
        SaveService.addGems(1);
        _playSound('coin_pickup.wav');
        break;
      case CollectibleType.heart:
        player.health = min(player.health + 3, player.maxHealth);
        healthNotifier.value = player.health;
        _playSound('key_pickup.wav');
        break;
      case CollectibleType.key:
        hasKeyNotifier.value = true;
        _playSound('key_pickup.wav');
        break;
      case CollectibleType.chest:
        if (hasKeyNotifier.value) {
          scoreNotifier.value += 100;
          hasKeyNotifier.value = false;
          _playSound('chest_open.wav');
        } else {
          scoreNotifier.value += 15;
          _playSound('coin_pickup.wav');
        }
        break;
    }
  }

  void _handlePlayerReachedExit() {
    _completeLevel();
  }

  void _handleGameOver() {
    statusNotifier.value = GameStatus.lost;
    _playSound('game_over.wav');
    HapticFeedback.heavyImpact();
    final level = currentLevel;
    if (level != null) {
      SaveService.setHighScoreIfBetter(level.levelNumber, scoreNotifier.value);
    }
  }

  // ---------------------------------------------------------------------
  // الانتقال المتحرك بين المراحل (بوابة + تصغير ودوران تلقائي للاعب)
  // ---------------------------------------------------------------------

  void _completeLevel() {
    if (statusNotifier.value != GameStatus.playing) return;
    final level = currentLevel;
    if (level == null) return;

    statusNotifier.value = GameStatus.transitioning;
    _playSound('portal_enter.wav');

    SaveService.unlockLevel(level.levelNumber + 1);
    SaveService.setHighScoreIfBetter(level.levelNumber, scoreNotifier.value);

    final exitCenter = _tileCenter(level.exitRow, level.exitCol);
    _transitionStart = player.position.clone();
    _transitionTarget = exitCenter;
    _transitionElapsed = 0;

    _spawnEffect(_portalSprite, exitCenter, size: 110, duration: 1.2, growTo: 2.6);
  }

  void _updateTransition(double dt) {
    _transitionElapsed = (_transitionElapsed ?? 0) + dt;
    final elapsed = _transitionElapsed!;

    if (elapsed <= _transitionMoveDuration) {
      final t = (elapsed / _transitionMoveDuration).clamp(0.0, 1.0);
      player.position = _transitionStart! + (_transitionTarget! - _transitionStart!) * t;
    } else {
      final shrinkElapsed = elapsed - _transitionMoveDuration;
      final t = (shrinkElapsed / _transitionShrinkDuration).clamp(0.0, 1.0);
      player.scale.setAll(max(0.0, 1 - t));
      player.angle += dt * 12;
      player.opacity = 1 - t;
      if (t >= 1.0) {
        _advanceToNextLevel();
      }
    }
  }

  Future<void> _advanceToNextLevel() async {
    final level = currentLevel;
    if (level == null) return;
    final next = level.levelNumber + 1;

    if (next > LevelGenerator.maxLevel) {
      statusNotifier.value = GameStatus.gameCompleted;
      return;
    }

    await loadLevel(next);
  }

  // ---------------------------------------------------------------------
  // أدوات مساعدة (تأثيرات بصرية وصوت وموسيقى)
  // ---------------------------------------------------------------------

  void _spawnEffect(Sprite sprite, Vector2 position, {double size = 50, double duration = 0.3, double growTo = 1.3}) {
    world.add(EffectSprite(
      sprite: sprite,
      position: position,
      size: Vector2.all(size),
      duration: duration,
      growTo: growTo,
    ));
  }

  void _playSound(String assetName) {
    if (!soundEnabledNotifier.value) return;
    FlameAudio.play(assetName).catchError((_) {});
  }

  void _playMusic() {
    FlameAudio.bgm.play('dungeon_theme.wav', volume: 0.35).catchError((_) {});
  }

  void toggleSound() {
    soundEnabledNotifier.value = !soundEnabledNotifier.value;
    SaveService.setSoundEnabled(soundEnabledNotifier.value);
  }

  void toggleMusic() {
    musicEnabledNotifier.value = !musicEnabledNotifier.value;
    SaveService.setMusicEnabled(musicEnabledNotifier.value);
    if (musicEnabledNotifier.value) {
      FlameAudio.bgm.resume().catchError((_) => _playMusic());
    } else {
      FlameAudio.bgm.pause().catchError((_) {});
    }
  }

  /// تُستدعى عند مغادرة شاشة اللعب حتى لا تتراكم أكثر من مقطوعة موسيقية بنفس الوقت.
  void stopMusic() {
    FlameAudio.bgm.stop().catchError((_) {});
  }

  /// إعادة تحميل مستويات ترقية الأسلحة (تُستدعى بعد شراء ترقية من المتجر إن كانت
  /// اللعبة ما زالت مفتوحة، عمليًا تُستخدم غالبًا فقط عند بدء لعبة جديدة).
  Future<void> refreshWeaponLevels() async {
    _weaponLevels = await SaveService.getAllWeaponLevels();
  }

  /// إعادة تشغيل نفس المرحلة الحالية (تُستخدم من شاشة الخسارة).
  Future<void> retryCurrentLevel() async {
    final level = currentLevel;
    if (level == null) return;
    scoreNotifier.value = 0;
    await loadLevel(level.levelNumber);
  }
}
