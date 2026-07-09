import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/effects_manager.dart';
import '../models/letter_model.dart';
import '../providers/audio_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';

class MatchingGame extends StatefulWidget {
  final List<LetterModel> letters;
  const MatchingGame({super.key, required this.letters});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  List<String> _options = [];
  String? _currentLetter;
  int _score = 0;
  int _attempts = 0;
  int _correctAnswers = 0;
  bool _isGameComplete = false;
  late List<LetterModel> _gameLetters;
  bool _showSuccessEffect = false;
  bool _showWrongEffect = false;

  @override
  void initState() {
    super.initState();
    _gameLetters = List.from(widget.letters);
    _gameLetters.shuffle();
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_gameLetters.isEmpty) {
      setState(() {
        _isGameComplete = true;
      });
      Provider.of<ProgressProvider>(context, listen: false)
          .updateGameScore(0, _score);
      return;
    }

    final current = _gameLetters.removeAt(0);
    setState(() {
      _currentLetter = current.character;
    });

    final allLetters = widget.letters.map((l) => l.character).toList();
    allLetters.shuffle();
    final selectedOptions = allLetters.take(3).toList();
    if (!selectedOptions.contains(current.character)) {
      selectedOptions[0] = current.character;
    }
    selectedOptions.shuffle();
    setState(() {
      _options = selectedOptions;
    });
  }

  void _checkAnswer(String selected) {
    final isCorrect = selected == _currentLetter;
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final progress = Provider.of<ProgressProvider>(context, listen: false);

    setState(() {
      _attempts++;
      if (isCorrect) {
        _correctAnswers++;
        _score += 10;
        _showSuccessEffect = true;
        audio.playSuccess();
        audio.playClap();
        Future.delayed(const Duration(milliseconds: 300), () {
          audio.playEncouragement();
        });
        progress.addStar();
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showSuccessEffect = false;
            });
          }
        });
      } else {
        _showWrongEffect = true;
        audio.playWrong();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showWrongEffect = false;
            });
          }
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_isGameComplete) {
        _nextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isArabic = language.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isArabic ? '🎯 لعبة المطابقة' : '🎯 Matching Game'),
        backgroundColor: AppColors.primary,
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
      body: Stack(
        children: [
          _isGameComplete
              ? _buildCompletionScreen(context)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _currentLetter ?? '?',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isArabic ? 'اختر الحرف الصحيح' : 'Choose the correct letter',
                          style: AppTheme.lightTheme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 40),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: _options.map((option) {
                            return GestureDetector(
                              onTap: () => _checkAnswer(option),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatChip(
                              icon: '✅',
                              label: isArabic ? 'صحيح' : 'Correct',
                              value: '$_correctAnswers',
                            ),
                            const SizedBox(width: 16),
                            _buildStatChip(
                              icon: '❌',
                              label: isArabic ? 'خطأ' : 'Wrong',
                              value: '${_attempts - _correctAnswers}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          if (_showSuccessEffect)
            EffectsManager.getFullSuccessEffect(context),
          if (_showWrongEffect)
            EffectsManager.getGentleWrongEffect(context),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isArabic = language.isArabic;
    final percentage = _attempts > 0 ? (_correctAnswers / _attempts * 100).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              percentage >= 80 ? '🏆' : '🌟',
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? percentage >= 80
                      ? 'ممتاز! 🎉'
                      : 'أحسنت! استمر في التدريب 💪'
                  : percentage >= 80
                      ? 'Excellent! 🎉'
                      : 'Good job! Keep practicing 💪',
              style: AppTheme.lightTheme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'أجبت على $_correctAnswers من $_attempts بشكل صحيح'
                  : 'You got $_correctAnswers out of $_attempts correct',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: percentage >= 80 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 80 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text(
                isArabic ? 'العودة' : 'Back',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}