import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';
import '../models/letter_model.dart';
import '../models/word_model.dart';
import '../services/storage_service.dart';
import '../games/matching_game.dart';
import '../games/memory_game.dart';
import '../games/word_builder.dart';
import '../games/letter_tracing.dart';
import '../games/quiz_game.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  List<LetterModel> _letters = [];
  List<WordModel> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final arabic = await StorageService().loadArabicLetters();
    final english = await StorageService().loadEnglishLetters();
    final words = await StorageService().loadWords();
    if (!mounted) return;
    setState(() {
      _letters = [...arabic, ...english];
      _words = words;
      _isLoading = false;
    });
  }

  void _openGame(String gameId, LanguageProvider language) {
    if (_letters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            language.isArabic
                ? '⏳ جاري تحميل البيانات، حاول مرة أخرى'
                : '⏳ Data still loading, please try again',
          ),
        ),
      );
      return;
    }

    Widget? game;
    switch (gameId) {
      case 'matching':
        game = MatchingGame(letters: _letters);
        break;
      case 'memory':
        game = MemoryGame(letters: _letters);
        break;
      case 'word_builder':
        game = WordBuilder(words: _words);
        break;
      case 'letter_tracing':
        game = LetterTracing(letters: _letters);
        break;
      case 'quiz':
        game = QuizGame(letters: _letters, words: _words);
        break;
    }

    if (game != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => game!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final language = Provider.of<LanguageProvider>(context);

    final games = [
      {
        'id': 'matching',
        'icon': '🎯',
        'title': language.isArabic ? 'مطابقة الحروف' : 'Letter Matching',
        'description': language.isArabic 
            ? 'طابق الحرف مع الصورة المناسبة'
            : 'Match the letter with the correct picture',
        'color': AppColors.primary,
        'score': progress.gameScores[0],
      },
      {
        'id': 'memory',
        'icon': '🃏',
        'title': language.isArabic ? 'لعبة الذاكرة' : 'Memory Game',
        'description': language.isArabic
            ? 'أوجد زوج الحرف والصورة'
            : 'Find the letter and picture pairs',
        'color': AppColors.blue,
        'score': progress.gameScores[1],
      },
      {
        'id': 'word_builder',
        'icon': '🧩',
        'title': language.isArabic ? 'ترتيب الحروف' : 'Word Builder',
        'description': language.isArabic
            ? 'رتب الحروف لتكوين كلمة'
            : 'Arrange the letters to form a word',
        'color': AppColors.accent,
        'score': progress.gameScores[2],
      },
      {
        'id': 'letter_tracing',
        'icon': '✏️',
        'title': language.isArabic ? 'تتبع الحروف' : 'Letter Tracing',
        'description': language.isArabic
            ? 'ارسم الحرف بإصبعك'
            : 'Trace the letter with your finger',
        'color': AppColors.purple,
        'score': progress.gameScores[3],
      },
      {
        'id': 'quiz',
        'icon': '📝',
        'title': language.isArabic ? 'اختبار سريع' : 'Quick Quiz',
        'description': language.isArabic
            ? 'أجب عن الأسئلة بسرعة'
            : 'Answer the questions quickly',
        'color': AppColors.orange,
        'score': progress.gameScores[4],
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          language.isArabic ? '🎮 الألعاب' : '🎮 Games',
        ),
        backgroundColor: AppColors.blue,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _buildGameCard(
                    icon: game['icon'] as String,
                    title: game['title'] as String,
                    description: game['description'] as String,
                    color: game['color'] as Color,
                    score: game['score'] as int,
                    onTap: () => _openGame(game['id'] as String, language),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildGameCard({
    required String icon,
    required String title,
    required String description,
    required Color color,
    required int score,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // أيقونة اللعبة
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // معلومات اللعبة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '⭐',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${score}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.star_border,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // زر التشغيل
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}