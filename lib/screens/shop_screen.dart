import 'package:flutter/material.dart';

import '../game/weapons.dart';
import '../services/save_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _coins = 0;
  Map<WeaponType, int> _levels = {};
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final coins = await SaveService.getTotalCoins();
    final levels = await SaveService.getAllWeaponLevels();
    setState(() {
      _coins = coins;
      _levels = levels;
      _loading = false;
    });
  }

  Future<void> _upgrade(WeaponType type) async {
    final success = await SaveService.tryUpgradeWeapon(type);
    if (!mounted) return;
    if (success) {
      setState(() => _message = null);
      await _load();
    } else {
      setState(() => _message = 'رصيد العملات غير كافٍ، أو السلاح بأعلى مستوى بالفعل');
    }
  }

  String _weaponName(WeaponType type) {
    switch (type) {
      case WeaponType.sword:
        return 'السيف';
      case WeaponType.bow:
        return 'القوس';
      case WeaponType.magic:
        return 'السحر';
      case WeaponType.bomb:
        return 'القنبلة';
    }
  }

  String _weaponIcon(WeaponType type) {
    switch (type) {
      case WeaponType.sword:
        return 'assets/sprites/weapons/icon_sword.png';
      case WeaponType.bow:
        return 'assets/sprites/weapons/icon_bow.png';
      case WeaponType.magic:
        return 'assets/sprites/weapons/icon_magic.png';
      case WeaponType.bomb:
        return 'assets/sprites/weapons/icon_bomb.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0714),
      appBar: AppBar(
        title: const Text('متجر الترقيات'),
        backgroundColor: const Color(0xFF1B1330),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('$_coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_message != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: Text(_message!, style: const TextStyle(color: Colors.redAccent)),
                  ),
                const Text(
                  'ارفع ضرر وسرعة أسلحتك بالعملات التي تجمعها أثناء اللعب. الترقيات تبقى محفوظة دائمًا.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 16),
                for (final type in WeaponType.values) _weaponCard(type),
              ],
            ),
    );
  }

  Widget _weaponCard(WeaponType type) {
    final level = _levels[type] ?? 1;
    final maxed = level >= SaveService.maxWeaponLevel;
    final cost = SaveService.upgradeCost(level);
    final canAfford = _coins >= cost;

    return Card(
      color: const Color(0xFF241C33),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(_weaponIcon(type)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weaponName(type),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      SaveService.maxWeaponLevel,
                      (i) => Icon(
                        i < level ? Icons.star : Icons.star_border,
                        color: Colors.amberAccent,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: maxed
                  ? const Center(
                      child: Text('الحد الأقصى', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    )
                  : ElevatedButton(
                      onPressed: canAfford ? () => _upgrade(type) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C4FD6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('ترقية', style: TextStyle(fontSize: 13)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text('$cost', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
