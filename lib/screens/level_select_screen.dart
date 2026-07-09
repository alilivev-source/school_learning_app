import 'package:flutter/material.dart';

import '../services/save_service.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlockedLevel = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final level = await SaveService.getUnlockedLevel();
    setState(() {
      _unlockedLevel = level;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0714),
      appBar: AppBar(
        title: const Text('اختيار المرحلة'),
        backgroundColor: const Color(0xFF1B1330),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: 100,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final unlocked = level <= _unlockedLevel;
                  return _LevelTile(
                    level: level,
                    unlocked: unlocked,
                    onTap: unlocked
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GameScreen(startLevel: level)),
                            )
                        : null,
                  );
                },
              ),
            ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final bool unlocked;
  final VoidCallback? onTap;

  const _LevelTile({required this.level, required this.unlocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFF3B2A66) : const Color(0xFF1E1826),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: unlocked ? Colors.deepPurpleAccent : Colors.white10),
        ),
        alignment: Alignment.center,
        child: unlocked
            ? Text(
                '$level',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              )
            : const Icon(Icons.lock, color: Colors.white24, size: 18),
      ),
    );
  }
}
