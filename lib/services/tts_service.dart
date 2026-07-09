import 'package:flutter_tts/flutter_tts.dart';

/// خدمة تحويل النص إلى كلام (منفصلة عن AudioProvider لإتاحة استخدامها
/// خارج شجرة الـ widgets، مثلاً داخل خدمات أخرى أو اختبارات)
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal() {
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.1);
  }

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> speak(String text, {required bool isArabic}) async {
    try {
      await _tts.setLanguage(isArabic ? 'ar' : 'en');
      _isSpeaking = true;
      await _tts.speak(text);
    } catch (_) {
      // تجاهل الخطأ
    } finally {
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);
  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);
}
