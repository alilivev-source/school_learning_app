import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/letter_model.dart';
import '../models/word_model.dart';
import '../models/story_model.dart';
import '../models/level_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box _progressBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _progressBox = await Hive.openBox('progressBox');
  }

  // ====== تحميل البيانات من ملفات JSON ======

  Future<List<LetterModel>> loadArabicLetters() async {
    try {
      String jsonString = await rootBundle.loadString('assets/json/arabic_letters.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List<dynamic> lettersJson = jsonData['letters'] ?? [];
      return lettersJson.map((json) => LetterModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LetterModel>> loadEnglishLetters() async {
    try {
      String jsonString = await rootBundle.loadString('assets/json/english_letters.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List<dynamic> lettersJson = jsonData['letters'] ?? [];
      return lettersJson.map((json) => LetterModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<WordModel>> loadWords() async {
    try {
      String jsonString = await rootBundle.loadString('assets/json/words.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List<dynamic> wordsJson = jsonData['words'] ?? [];
      return wordsJson.map((json) => WordModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<StoryModel>> loadStories() async {
    try {
      String jsonString = await rootBundle.loadString('assets/json/stories.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List<dynamic> storiesJson = jsonData['stories'] ?? [];
      return storiesJson.map((json) => StoryModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LevelModel>> loadLevels() async {
    try {
      String jsonString = await rootBundle.loadString('assets/json/levels.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List<dynamic> levelsJson = jsonData['levels'] ?? [];
      return levelsJson.map((json) => LevelModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // ====== حفظ واسترجاع التقدم ======

  void saveProgress(String key, dynamic value) {
    _progressBox.put(key, value);
  }

  dynamic getProgress(String key, {dynamic defaultValue}) {
    return _progressBox.get(key, defaultValue: defaultValue);
  }

  // حفظ تقدم المستوى
  void saveLevelProgress(int level, Map<String, dynamic> data) {
    _progressBox.put('level_$level', data);
  }

  Map<String, dynamic>? getLevelProgress(int level) {
    return _progressBox.get('level_$level');
  }

  // حفظ الحروف المكتملة
  void saveCompletedLetters(List<String> letters) {
    _progressBox.put('completed_letters', letters);
  }

  List<String> getCompletedLetters() {
    return _progressBox.get('completed_letters', defaultValue: <String>[]).cast<String>();
  }

  // حفظ الكلمات المكتملة
  void saveCompletedWords(List<String> words) {
    _progressBox.put('completed_words', words);
  }

  List<String> getCompletedWords() {
    return _progressBox.get('completed_words', defaultValue: <String>[]).cast<String>();
  }

  // حفظ النجوم
  void saveTotalStars(int stars) {
    _progressBox.put('total_stars', stars);
  }

  int getTotalStars() {
    return _progressBox.get('total_stars', defaultValue: 0);
  }

  // حفظ المستوى الحالي
  void saveCurrentLevel(int level) {
    _progressBox.put('current_level', level);
  }

  int getCurrentLevel() {
    return _progressBox.get('current_level', defaultValue: 1);
  }

  // حفظ درجات الألعاب
  void saveGameScore(int gameIndex, int score) {
    _progressBox.put('game_score_$gameIndex', score);
  }

  int getGameScore(int gameIndex) {
    return _progressBox.get('game_score_$gameIndex', defaultValue: 0);
  }

  // حفظ تقدم اليوم
  void saveTodayProgress(int exercises, int stars) {
    String today = DateTime.now().toString().substring(0, 10);
    _progressBox.put('exercises_$today', exercises);
    _progressBox.put('daily_stars_$today', stars);
  }

  int getTodayExercises() {
    String today = DateTime.now().toString().substring(0, 10);
    return _progressBox.get('exercises_$today', defaultValue: 0);
  }

  int getTodayStars() {
    String today = DateTime.now().toString().substring(0, 10);
    return _progressBox.get('daily_stars_$today', defaultValue: 0);
  }

  // حفظ إعدادات التطبيق
  void saveSettings(String key, dynamic value) {
    _progressBox.put('settings_$key', value);
  }

  dynamic getSettings(String key, {dynamic defaultValue}) {
    return _progressBox.get('settings_$key', defaultValue: defaultValue);
  }

  // مسح جميع البيانات (إعادة تعيين)
  void clearAllData() {
    _progressBox.clear();
  }
}