import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/letter_model.dart';
import '../models/word_model.dart';

class ProgressProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  int _currentLevel = 1;
  int _totalStars = 0;
  List<String> _completedLetters = [];
  List<String> _completedWords = [];
  List<int> _gameScores = [0, 0, 0, 0, 0];
  Map<String, int> _dailyProgress = {};
  int _todayExercises = 0;
  String _lastUsed = '';

  ProgressProvider(this._prefs) {
    _loadProgress();
  }

  // Getters
  int get currentLevel => _currentLevel;
  int get totalStars => _totalStars;
  List<String> get completedLetters => _completedLetters;
  List<String> get completedWords => _completedWords;
  List<int> get gameScores => _gameScores;
  int get todayExercises => _todayExercises;
  String get lastUsed => _lastUsed;

  // تحميل التقدم من التخزين
  void _loadProgress() {
    _currentLevel = _prefs.getInt(AppConstants.keyCurrentLevel) ?? 1;
    _totalStars = _prefs.getInt(AppConstants.keyTotalStars) ?? 0;
    _completedLetters = _prefs.getStringList(AppConstants.keyCompletedLetters) ?? [];
    _lastUsed = _prefs.getString(AppConstants.keyLastUsed) ?? '';
    
    // تحميل درجات الألعاب
    for (int i = 0; i < _gameScores.length; i++) {
      _gameScores[i] = _prefs.getInt('game_score_$i') ?? 0;
    }
    
    // تحميل تقدم اليوم
    String today = DateTime.now().toString().substring(0, 10);
    _todayExercises = _prefs.getInt('exercises_$today') ?? 0;
  }

  // حفظ التقدم
  void _saveProgress() {
    _prefs.setInt(AppConstants.keyCurrentLevel, _currentLevel);
    _prefs.setInt(AppConstants.keyTotalStars, _totalStars);
    _prefs.setStringList(AppConstants.keyCompletedLetters, _completedLetters);
    _prefs.setString(AppConstants.keyLastUsed, DateTime.now().toString());
    
    for (int i = 0; i < _gameScores.length; i++) {
      _prefs.setInt('game_score_$i', _gameScores[i]);
    }
    
    String today = DateTime.now().toString().substring(0, 10);
    _prefs.setInt('exercises_$today', _todayExercises);
    
    notifyListeners();
  }

  // إضافة نجمة
  void addStar() {
    _totalStars++;
    _todayExercises++;
    _saveProgress();
  }

  // إضافة عدة نجوم
  void addStars(int count) {
    _totalStars += count;
    _todayExercises += count;
    _saveProgress();
  }

  // إنفاق نجوم (عند شراء ملصق من المتجر)
  bool spendStars(int count) {
    if (_totalStars < count) return false;
    _totalStars -= count;
    _saveProgress();
    return true;
  }

  // إكمال حرف
  void completeLetter(String letterId) {
    if (!_completedLetters.contains(letterId)) {
      _completedLetters.add(letterId);
      addStar();
    }
  }

  // إكمال كلمة
  void completeWord(String wordId) {
    if (!_completedWords.contains(wordId)) {
      _completedWords.add(wordId);
      addStars(2);
    }
  }

  // تحديث درجة اللعبة
  void updateGameScore(int gameIndex, int score) {
    if (gameIndex >= 0 && gameIndex < _gameScores.length) {
      if (score > _gameScores[gameIndex]) {
        _gameScores[gameIndex] = score;
        _saveProgress();
      }
    }
  }

  // التقدم للمستوى التالي
  bool advanceLevel() {
    int maxLevel = 5;
    if (_currentLevel < maxLevel) {
      _currentLevel++;
      _saveProgress();
      return true;
    }
    return false;
  }

  // هل الحرف مكتمل
  bool isLetterCompleted(String letterId) {
    return _completedLetters.contains(letterId);
  }

  // هل الكلمة مكتملة
  bool isWordCompleted(String wordId) {
    return _completedWords.contains(wordId);
  }

  // نسبة التقدم في مستوى معين
  double getLevelProgress(int level, List<LetterModel> letters) {
    int totalLetters = letters.where((l) => l.level == level).length;
    if (totalLetters == 0) return 0.0;
    
    int completed = letters
        .where((l) => l.level == level && _completedLetters.contains(l.id))
        .length;
    
    return completed / totalLetters;
  }

  // نقاط اليوم
  int get dailyStars {
    String today = DateTime.now().toString().substring(0, 10);
    return _prefs.getInt('daily_stars_$today') ?? 0;
  }

  // إعادة تعيين التقدم (للاختبار)
  void resetProgress() {
    _currentLevel = 1;
    _totalStars = 0;
    _completedLetters = [];
    _completedWords = [];
    _gameScores = [0, 0, 0, 0, 0];
    _todayExercises = 0;
    _saveProgress();
  }

  // الحصول على إحصائيات الوالدين
  Map<String, dynamic> getParentReport() {
    return {
      'currentLevel': _currentLevel,
      'totalStars': _totalStars,
      'completedLetters': _completedLetters.length,
      'completedWords': _completedWords.length,
      'todayExercises': _todayExercises,
      'gameScores': _gameScores,
      'lastUsed': _lastUsed,
      'dailyAverage': _calculateDailyAverage(),
    };
  }

  // حساب متوسط التمارين اليومية
  double _calculateDailyAverage() {
    // نسخة مبسطة
    return _todayExercises > 0 ? _todayExercises.toDouble() : 0.0;
  }
}