/// نموذج بيانات يمثّل لقطة (Snapshot) لتقدّم المستخدم
/// يُستخدم لتصدير/استيراد بيانات التقدّم (مثل مشاركتها مع ولي الأمر أو نسخها احتياطياً)
class UserProgress {
  final int currentLevel;
  final int totalStars;
  final List<String> completedLetters;
  final List<String> completedWords;
  final List<int> gameScores;
  final Map<String, int> dailyProgress;
  final int todayExercises;
  final String lastUsed;

  UserProgress({
    this.currentLevel = 1,
    this.totalStars = 0,
    this.completedLetters = const [],
    this.completedWords = const [],
    this.gameScores = const [0, 0, 0, 0, 0],
    this.dailyProgress = const {},
    this.todayExercises = 0,
    this.lastUsed = '',
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentLevel: json['currentLevel'] ?? 1,
      totalStars: json['totalStars'] ?? 0,
      completedLetters: List<String>.from(json['completedLetters'] ?? []),
      completedWords: List<String>.from(json['completedWords'] ?? []),
      gameScores: List<int>.from(json['gameScores'] ?? [0, 0, 0, 0, 0]),
      dailyProgress: Map<String, int>.from(json['dailyProgress'] ?? {}),
      todayExercises: json['todayExercises'] ?? 0,
      lastUsed: json['lastUsed'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'totalStars': totalStars,
      'completedLetters': completedLetters,
      'completedWords': completedWords,
      'gameScores': gameScores,
      'dailyProgress': dailyProgress,
      'todayExercises': todayExercises,
      'lastUsed': lastUsed,
    };
  }

  UserProgress copyWith({
    int? currentLevel,
    int? totalStars,
    List<String>? completedLetters,
    List<String>? completedWords,
    List<int>? gameScores,
    Map<String, int>? dailyProgress,
    int? todayExercises,
    String? lastUsed,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      totalStars: totalStars ?? this.totalStars,
      completedLetters: completedLetters ?? this.completedLetters,
      completedWords: completedWords ?? this.completedWords,
      gameScores: gameScores ?? this.gameScores,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      todayExercises: todayExercises ?? this.todayExercises,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
