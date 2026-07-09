import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';

class EffectsManager {
  static final EffectsManager _instance = EffectsManager._internal();
  factory EffectsManager() => _instance;
  EffectsManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ====== التأثيرات البصرية ======

  // نجمة متطايرة عند الإجابة الصحيحة
  static Widget getStarAnimation() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          '⭐',
          style: TextStyle(fontSize: 40),
        ),
      ),
    ).animate()
      .scale(duration: 300.ms, curve: Curves.easeOutBack)
      .then()
      .fadeOut(duration: 500.ms, delay: 500.ms);
  }

  // ألعاب نارية عند إكمال مستوى
  static Widget getFireworksEffect(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];

    return Stack(
      children: List.generate(12, (index) {
        final color = colors[index % colors.length];
        final startX = 0.2 + (index * 0.05);
        final startY = 0.3 + (index * 0.02);
        final endX = 0.1 + (index * 0.08);
        final endY = 0.4 + (index * 0.03);

        return Positioned(
          left: MediaQuery.of(context).size.width * startX,
          top: MediaQuery.of(context).size.height * startY,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ).animate()
            .move(
              begin: Offset(0, 0),
              end: Offset(
                (endX - startX) * 400,
                (endY - startY) * 400,
              ),
              duration: 800.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeOut(duration: 500.ms, delay: 300.ms),
        );
      }),
    );
  }

  // تأثير قلوب متطايرة
  static Widget getHeartsEffect(BuildContext context) {
    final hearts = ['❤️', '🧡', '💛', '💚', '💙', '💜', '🩷', '🤍'];

    return Stack(
      children: List.generate(8, (index) {
        final startX = 0.1 + (index * 0.1);
        final startY = 0.4 + (index * 0.02);

        return Positioned(
          left: MediaQuery.of(context).size.width * startX,
          top: MediaQuery.of(context).size.height * startY,
          child: Text(
            hearts[index % hearts.length],
            style: const TextStyle(fontSize: 30),
          ).animate()
            .moveY(
              begin: 0,
              end: -200 - (index * 20).toDouble(),
              duration: 1500.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeOut(duration: 500.ms, delay: 1000.ms)
            .rotate(
              begin: 0,
              end: 0.5,
              duration: 1000.ms,
            ),
        );
      }),
    );
  }

  // تأثير نجمة واحدة متحركة
  static Widget getSingleStarAnimation() {
    return const Text(
      '⭐',
      style: TextStyle(fontSize: 80),
    ).animate()
      .scale(
        begin: 0.5,
        end: 1.2,
        duration: 500.ms,
        curve: Curves.easeOutBack,
      )
      .then()
      .fadeOut(duration: 500.ms, delay: 500.ms);
  }

  // تأثير موجة مبهجة
  static Widget getWaveEffect() {
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFFD700),
            Colors.transparent,
          ],
        ),
      ),
    ).animate()
      .scaleX(
        begin: 0,
        end: 1,
        duration: 600.ms,
        curve: Curves.easeInOut,
      )
      .then()
      .fadeOut(duration: 400.ms, delay: 400.ms);
  }

  // ====== التأثيرات الصوتية (أوفلاين) ======

  // تشغيل صوت مع تحميل من مجلد assets
  Future<void> playEffect(String soundName) async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/$soundName.mp3'),
        volume: 0.8,
      );
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  // صوت نجاح
  Future<void> playSuccessSound() async {
    await playEffect('success');
  }

  // صوت تصفيق
  Future<void> playClapSound() async {
    await playEffect('clap');
  }

  // صوت تشجيع
  Future<void> playEncouragementSound() async {
    await playEffect('encouragement');
  }

  // صوت خطأ لطيف
  Future<void> playWrongSound() async {
    await playEffect('wrong');
  }

  // تشغيل موسيقى خلفية (حلقة)
  Future<void> playBackgroundMusic() async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/background.mp3'),
        volume: 0.3,
      );
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  // إيقاف الموسيقى
  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
  }

  // ====== تأثيرات مركبة ======

  // تأثير كامل عند الإجابة الصحيحة
  static Widget getFullSuccessEffect(BuildContext context) {
    return Stack(
      children: [
        // النجوم المتطايرة
        Positioned.fill(
          child: Stack(
            children: List.generate(5, (index) {
            final randomX = 0.1 + (index * 0.2);
            final randomY = 0.2 + (index * 0.1);
            return Positioned(
              left: MediaQuery.of(context).size.width * randomX,
              top: MediaQuery.of(context).size.height * randomY,
              child: Text(
                '⭐',
                style: TextStyle(fontSize: 30 + index * 5.0),
              ).animate()
                .moveY(
                  begin: 0,
                  end: -100 - (index * 30).toDouble(),
                  duration: 1000.ms + Duration(milliseconds: index * 100),
                )
                .fadeOut(
                  duration: 500.ms,
                  delay: 500.ms + Duration(milliseconds: index * 100),
                )
                .rotate(
                  begin: 0,
                  end: 1 + index * 0.2,
                  duration: 1000.ms + Duration(milliseconds: index * 100),
                ),
            );
            }),
          ),
        ),
        // القلب الكبير في المنتصف
        Center(
          child: const Text(
            '❤️',
            style: TextStyle(fontSize: 100),
          ).animate()
            .scale(
              begin: 0.5,
              end: 1.5,
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .then()
            .fadeOut(duration: 500.ms, delay: 500.ms),
        ),
        // نص التشجيع
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 120),
            child: const Text(
              'أحسنت! 🎉',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                  ),
                ],
              ),
            ).animate()
              .scale(
                begin: 0.5,
                end: 1.2,
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .fadeOut(duration: 500.ms, delay: 800.ms),
          ),
        ),
      ],
    );
  }

  // تأثير خطأ لطيف
  static Widget getGentleWrongEffect(BuildContext context) {
    return Stack(
      children: [
        // تموجات حمراء خفيفة
        Positioned.fill(
          child: Container(
            color: Colors.red.withOpacity(0.05),
          ).animate()
            .fadeOut(duration: 500.ms),
        ),
        // علامة خطأ لطيفة
        Center(
          child: const Text(
            '😊',
            style: TextStyle(fontSize: 80),
          ).animate()
            .scale(
              begin: 0.5,
              end: 1.2,
              duration: 400.ms,
              curve: Curves.easeOutBack,
            )
            .then()
            .fadeOut(duration: 400.ms, delay: 400.ms),
        ),
        // نص تشجيع
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 120),
            child: const Text(
              'حاول مرة أخرى! 💪',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                  ),
                ],
              ),
            ).animate()
              .scale(
                begin: 0.5,
                end: 1.1,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .fadeOut(duration: 400.ms, delay: 600.ms),
          ),
        ),
      ],
    );
  }

  // ====== تنظيف الموارد ======

  void dispose() {
    _audioPlayer.dispose();
  }
}

// واجهة سهلة الاستخدام للتأثيرات
class EffectOverlay extends StatefulWidget {
  final Widget child;
  final bool showSuccess;
  final bool showWrong;
  final VoidCallback? onComplete;

  const EffectOverlay({
    super.key,
    required this.child,
    this.showSuccess = false,
    this.showWrong = false,
    this.onComplete,
  });

  @override
  State<EffectOverlay> createState() => _EffectOverlayState();
}

class _EffectOverlayState extends State<EffectOverlay> {
  @override
  void didUpdateWidget(EffectOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showSuccess && !oldWidget.showSuccess) {
      _playSuccessEffect();
    }
    if (widget.showWrong && !oldWidget.showWrong) {
      _playWrongEffect();
    }
  }

  void _playSuccessEffect() {
    final effects = EffectsManager();
    effects.playSuccessSound();
    effects.playClapSound();
    Future.delayed(const Duration(milliseconds: 300), () {
      effects.playEncouragementSound();
    });
    Future.delayed(const Duration(seconds: 2), () {
      widget.onComplete?.call();
    });
  }

  void _playWrongEffect() {
    final effects = EffectsManager();
    effects.playWrongSound();
    Future.delayed(const Duration(seconds: 1), () {
      widget.onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showSuccess)
          EffectsManager.getFullSuccessEffect(context),
        if (widget.showWrong)
          EffectsManager.getGentleWrongEffect(context),
      ],
    );
  }
}