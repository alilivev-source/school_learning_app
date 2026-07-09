import 'package:flutter/material.dart';

import '../services/save_service.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'shop_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1330), Color(0xFF0A0714)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.castle, color: Colors.deepPurpleAccent, size: 72),
                const SizedBox(height: 16),
                const Text(
                  'Mystic Dungeon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'محارب ضد 100 مرحلة من الوحوش',
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
                const SizedBox(height: 48),
                FutureBuilder<int>(
                  future: SaveService.getUnlockedLevel(),
                  builder: (context, snapshot) {
                    final unlocked = snapshot.data ?? 1;
                    return Column(
                      children: [
                        _MenuButton(
                          label: unlocked > 1 ? 'استكمال اللعب (مرحلة $unlocked)' : 'ابدأ اللعب',
                          icon: Icons.play_arrow,
                          color: const Color(0xFF6C4FD6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => GameScreen(startLevel: unlocked)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _MenuButton(
                          label: 'اختيار المرحلة',
                          icon: Icons.grid_view_rounded,
                          color: const Color(0xFF4F8FD6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: 'متجر الترقيات',
                  icon: Icons.shopping_bag,
                  color: const Color(0xFF4FD68F),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  label: 'بدء جديد (تصفير التقدم)',
                  icon: Icons.restart_alt,
                  color: const Color(0xFF4F4F4F),
                  onTap: () async {
                    await SaveService.resetProgress();
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GameScreen(startLevel: 1)),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
