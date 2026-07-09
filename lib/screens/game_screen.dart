import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/dungeon_game.dart';
import '../game/game_status.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/status_overlays.dart';

class GameScreen extends StatefulWidget {
  final int startLevel;

  const GameScreen({super.key, required this.startLevel});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final DungeonGame _game;

  @override
  void initState() {
    super.initState();
    _game = DungeonGame(startLevel: widget.startLevel);
    _game.statusNotifier.addListener(_syncOverlays);
  }

  void _syncOverlays() {
    final overlays = _game.overlays;
    overlays.remove('pause');
    overlays.remove('gameover');
    overlays.remove('victory');

    switch (_game.statusNotifier.value) {
      case GameStatus.paused:
        overlays.add('pause');
        break;
      case GameStatus.lost:
        overlays.add('gameover');
        break;
      case GameStatus.gameCompleted:
        overlays.add('victory');
        break;
      default:
        break;
    }
  }

  void _exitToMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _game.statusNotifier.removeListener(_syncOverlays);
    _game.stopMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120E1A),
      body: GameWidget(
        game: _game,
        initialActiveOverlays: const ['hud'],
        overlayBuilderMap: {
          'hud': (context, DungeonGame game) => HudOverlay(game: game),
          'pause': (context, DungeonGame game) => PauseOverlay(game: game, onExitToMenu: _exitToMenu),
          'gameover': (context, DungeonGame game) => GameOverOverlay(game: game, onExitToMenu: _exitToMenu),
          'victory': (context, DungeonGame game) => VictoryOverlay(game: game, onExitToMenu: _exitToMenu),
        },
      ),
    );
  }
}
