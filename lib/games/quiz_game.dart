import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/letter_model.dart';
import '../models/word_model.dart';
import '../providers/audio_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';

class QuizGame extends StatefulWidget {
  final List<LetterModel> letters;
  final List<WordModel> words;
  const QuizGame({super.key, required this.letters, required this.words});

  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  bool _isAnswered = false;
  bool _isGameComplete = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    final questions = <Map<String, dynamic>>[];
    final language = Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = language.isArabic;

    // أسئلة الحروف
    for (var letter in widget.letters) {
      final options = widget.letters
          .where((l) => l.id != letter.id)
          .toList();
      options.shuffle();
      final selectedOptions = options.take(3).toList();
      final allOptions = [letter, ...selectedOptions];
      allOptions.shuffle();
      
      questions.add({
        'type': 'letter',
        'question': isArabic
            ? 'ما هو اسم هذا الحرف؟'
            : 'What is the name of this letter?',
        'display': letter.character,
        'correctIndex': allOptions.indexOf(letter),
        'options': allOptions.map((l) => isArabic ? l.name : l.nameEn).toList(),
        'correctAnswer': isArabic ? letter.name : letter.nameEn,
        'letterId': letter.id,
      });
    }

    // أسئلة الكلمات (إذا وجدت)
    for (var word in widget.words) {
      final options = widget.words
          .where((w) => w.id != word.id)
          .toList();
      options.shuffle();
      final selectedOptions = options.take(3).toList();
      final allOptions = [word, ...selectedOptions];
      allOptions.shuffle();
      
      questions.add({
        'type': 'word',
        'question': isArabic
            ? 'ماذا تعني هذه الصورة؟'
            : 'What does this picture mean?',
        'display': word.emoji,
        'correctIndex': allOptions.indexOf(word),
        'options': allOptions.map((w) => isArabic ? w.arabic : w.english).toList(),
        'correctAnswer': isArabic ? word.arabic : word.english,
        'wordId': word.id,
      });
    }

    questions.shuffle();
    setState(() {
      _questions = questions.take(10).toList();
      _totalQuestions = _questions.length;
      _currentQuestionIndex = 0;
      _score = 0;
      _correctAnswers = 0;
      _isAnswered = false;
      _isGameComplete = false;
    });
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question['correctIndex'];
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final progress = Provider.of<ProgressProvider>(context, listen: false);

    setState(() {
      _isAnswered = true;
      if (isCorrect) {
        _score += 10;
        _correctAnswers++;
        progress.addStar();
        audio.playSuccess();
      } else {
        audio.playWrong();
      }
    });

    // الانتقال للسؤال التالي
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (_currentQuestionIndex + 1 < _totalQuestions) {
          setState(() {
            _currentQuestionIndex++;
            _isAnswered = false;
          });
        } else {
          setState(() {
            _isGameComplete = true;
          });
          progress.updateGameScore(4, _score);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isArabic = language.isArabic;

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isArabic ? '📝 اختبار' : '📝 Quiz'),
          backgroundColor: AppColors.orange,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isGameComplete) {
      return _buildCompletionScreen(context);
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isArabic ? '📝 اختبار' : '📝 Quiz'),
        backgroundColor: AppColors.orange,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // شريط التقدم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentQuestionIndex + 1}/$_totalQuestions',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _totalQuestions,
                      backgroundColor: Colors.grey.shade300,
                      color: AppColors.orange,
                      minHeight: 8,
                      semanticsLabel: 'Progress',
                    ),
                  ),
                  Text(
                    '${((_currentQuestionIndex + 1) / _totalQuestions * 100).toInt()}%',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // السؤال
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // عرض السؤال
                  Text(
                    question['display'] as String,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question['question'] as String,
                    style: AppTheme.lightTheme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // خيارات الإجابة
            Expanded(
              child: ListView.builder(
                itemCount: (question['options'] as List).length,
                itemBuilder: (context, index) {
                  final isCorrect = index == question['correctIndex'];
                  final isSelected = _isAnswered && index == question['correctIndex'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: _isAnswered ? null : () => _checkAnswer(index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isAnswered
                              ? isCorrect
                                  ? Colors.green.withOpacity(0.1)
                                  : index == question['correctIndex']
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isAnswered
                                ? isCorrect
                                    ? Colors.green
                                    : index == question['correctIndex']
                                        ? Colors.green
                                        : Colors.red
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _isAnswered && isCorrect
                                    ? Colors.green
                                    : _isAnswered && index == question['correctIndex']
                                        ? Colors.green
                                        : _isAnswered
                                            ? Colors.red
                                            : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: _isAnswered ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (question['options'] as List)[index] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isAnswered
                                      ? isCorrect || index == question['correctIndex']
                                          ? Colors.green
                                          : Colors.red
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (_isAnswered && isCorrect)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            if (_isAnswered && !isCorrect && index == question['correctIndex'])
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            if (_isAnswered && !isCorrect && index != question['correctIndex'])
                              const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isArabic = language.isArabic;
    final percentage = (_correctAnswers / _totalQuestions * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isArabic ? '📝 نتيجة الاختبار' : '📝 Quiz Results'),
        backgroundColor: AppColors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                percentage >= 80 ? '🎉' : '💪',
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? percentage >= 80
                        ? 'ممتاز! 🏆'
                        : 'أحسنت! استمر في التدريب'
                    : percentage >= 80
                        ? 'Excellent! 🏆'
                        : 'Good job! Keep practicing',
                style: AppTheme.lightTheme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'أجبت على $_correctAnswers من $_totalQuestions بشكل صحيح'
                    : 'You got $_correctAnswers out of $_totalQuestions correct',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: percentage >= 80 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 80 ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      isArabic ? 'نسبة النجاح' : 'Success Rate',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          '$_score',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _generateQuestions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      isArabic ? 'اختبار جديد' : 'New Quiz',
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      isArabic ? 'العودة' : 'Back',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}