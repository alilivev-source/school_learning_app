import 'package:flutter/material.dart';
import '../models/game_model.dart';

/// يدير قائمة الألعاب المتاحة في التطبيق وحالة كل لعبة (نتيجة، فتح/قفل)
class GameProvider extends ChangeNotifier {
  final List<GameModel> _games = GameModel.defaultGames();
  List<int> _scores = [0, 0, 0, 0, 0];

  List<GameModel> get games => _games;
  List<int> get scores => _scores;

  /// تحديث نتيجة لعبة معيّنة عبر رقمها التسلسلي
  void updateScore(int index, int score) {
    if (index < 0 || index >= _scores.length) return;
    if (score > _scores[index]) {
      _scores[index] = score;
      notifyListeners();
    }
  }

  /// مزامنة النتائج مع البيانات المخزّنة في مزود التقدّم
  void syncScores(List<int> scores) {
    _scores = List<int>.from(scores);
    notifyListeners();
  }

  /// إجمالي النقاط عبر كل الألعاب
  int get totalScore => _scores.fold(0, (a, b) => a + b);

  /// الحصول على بيانات لعبة معيّنة عبر معرّفها
  GameModel? getGameById(String id) {
    try {
      return _games.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}
