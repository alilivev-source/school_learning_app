import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // نجعل مسار تحميل الصور يطابق بنية مجلد assets الفعلية في هذا المشروع
  // (assets/sprites/..., assets/backgrounds/...) بدل الافتراضي assets/images/.
  Flame.images.prefix = 'assets/';

  // نفس الفكرة لمكتبة الصوت: كل الأصوات موجودة داخل assets/sounds/.
  FlameAudio.audioCache.prefix = 'assets/sounds/';

  // تثبيت الاتجاه الرأسي فقط، لأن اللعبة مصممة للعب بالإصبعين على الجوال.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MysticDungeonApp());
}

class MysticDungeonApp extends StatelessWidget {
  const MysticDungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mystic Dungeon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainMenuScreen(),
    );
  }
}
