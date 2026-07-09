import 'package:audioplayers/audioplayers.dart';

/// خدمة عامة لتشغيل ملفات صوتية من مجلد assets/sounds
/// (منفصلة عن EffectsManager الذي يوفّر اختصارات جاهزة للمؤثرات الشائعة)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _loopPlayer = AudioPlayer();

  /// تشغيل ملف صوتي لمرة واحدة من assets/sounds/<fileName>
  Future<void> playOnce(String fileName, {double volume = 1.0}) async {
    try {
      await _player.play(AssetSource('sounds/$fileName'), volume: volume);
    } catch (_) {
      // تجاهل الخطأ
    }
  }

  /// تشغيل ملف صوتي في حلقة متكررة (مناسب للموسيقى الخلفية)
  Future<void> playLoop(String fileName, {double volume = 0.3}) async {
    try {
      await _loopPlayer.setReleaseMode(ReleaseMode.loop);
      await _loopPlayer.play(AssetSource('sounds/$fileName'), volume: volume);
    } catch (_) {
      // تجاهل الخطأ
    }
  }

  Future<void> stopLoop() async {
    try {
      await _loopPlayer.stop();
    } catch (_) {
      // تجاهل الخطأ
    }
  }

  Future<void> setLoopVolume(double volume) async {
    try {
      await _loopPlayer.setVolume(volume);
    } catch (_) {
      // تجاهل الخطأ
    }
  }

  void dispose() {
    _player.dispose();
    _loopPlayer.dispose();
  }
}
