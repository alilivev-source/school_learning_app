import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/effects_manager.dart';

class AudioProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SharedPreferences? _prefs;

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isSpeaking = false;

  AudioProvider([this._prefs]) {
    _loadSettings();
    _setupTts();
  }

  // Getters
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSpeaking => _isSpeaking;

  // تحميل الإعدادات
  void _loadSettings() {
    if (_prefs != null) {
      _isSoundEnabled = _prefs!.getBool(AppConstants.keySoundEnabled) ?? true;
      _isMusicEnabled = _prefs!.getBool(AppConstants.keyMusicEnabled) ?? true;
    }
  }

  // حفظ الإعدادات
  void _saveSettings() {
    if (_prefs != null) {
      _prefs!.setBool(AppConstants.keySoundEnabled, _isSoundEnabled);
      _prefs!.setBool(AppConstants.keyMusicEnabled, _isMusicEnabled);
    }
    notifyListeners();
  }

  // إعداد TTS
  void _setupTts() {
    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _tts.setErrorHandler((message) {
      _isSpeaking = false;
      notifyListeners();
    });

    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.1);
  }

  // نطق نص بالعربية
  Future<void> speakArabic(String text) async {
    if (!_isSoundEnabled) return;
    try {
      await _tts.setLanguage('ar');
      await _tts.setVoice('ar-x-arb-network');
      await _tts.speak(text);
    } catch (e) {
      try {
        await _tts.setLanguage('ar');
        await _tts.speak(text);
      } catch (e) {
        // تجاهل الخطأ
      }
    }
  }

  // نطق نص بالإنجليزية
  Future<void> speakEnglish(String text) async {
    if (!_isSoundEnabled) return;
    try {
      await _tts.setLanguage('en');
      await _tts.setVoice('en-us-x-sfg-local');
      await _tts.speak(text);
    } catch (e) {
      try {
        await _tts.setLanguage('en');
        await _tts.speak(text);
      } catch (e) {
        // تجاهل الخطأ
      }
    }
  }

  // نطق حرف مع حركة
  Future<void> speakLetter(String letter, String haraka, bool isArabic) async {
    String text = letter;
    if (haraka.isNotEmpty) {
      text += haraka;
    }
    if (isArabic) {
      await speakArabic(text);
    } else {
      await speakEnglish(text);
    }
  }

  // ====== المؤثرات الصوتية ======

  // تشغيل صوت تصفيق
  Future<void> playClap() async {
    if (!_isSoundEnabled) return;
    await EffectsManager().playClapSound();
  }

  // تشغيل صوت نجاح
  Future<void> playSuccess() async {
    if (!_isSoundEnabled) return;
    await EffectsManager().playSuccessSound();
  }

  // تشغيل صوت تشجيع
  Future<void> playEncouragement() async {
    if (!_isSoundEnabled) return;
    await EffectsManager().playEncouragementSound();
  }

  // تشغيل صوت خطأ (لطيف)
  Future<void> playWrong() async {
    if (!_isSoundEnabled) return;
    await EffectsManager().playWrongSound();
  }

  // تشغيل موسيقى خلفية
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    await EffectsManager().playBackgroundMusic();
  }

  // إيقاف الموسيقى
  Future<void> stopBackgroundMusic() async {
    await EffectsManager().stopBackgroundMusic();
  }

  // تشغيل/إيقاف الموسيقى الخلفية
  Future<void> toggleMusic(bool enable) async {
    _isMusicEnabled = enable;
    _saveSettings();
    if (enable) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  // تشغيل/إيقاف الأصوات
  void toggleSound(bool enable) {
    _isSoundEnabled = enable;
    _saveSettings();
    if (!enable) {
      _tts.stop();
    }
  }

  // إيقاف الكلام
  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  // تنظيف الموارد
  @override
  void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}