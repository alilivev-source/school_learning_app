import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/word_model.dart';
import '../providers/audio_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';

class WordBuilder extends StatefulWidget {
  final List<WordModel> words;
  const WordBuilder({super.key, required this.words});

  @override
  State<WordBuilder> createState() => _WordBuilderState();
}

class _WordBuilderState extends State<WordBuilder> {
  List<WordModel> _gameWords = [];
  WordModel? _currentWord;
  List<String> _shuffledLetters = [];
  List<String> _selectedLetters = [];
  int _score = 0;
  int _completedWords = 0;
  bool _isGameComplete = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final shuffledWords = List.from(widget.words);
    shuffledWords.shuffle();
    _gameWords = shuffledWords.take(5).toList();
    _completedWords = 0;
    _score = 0;
    _nextWord();
  }

  void _nextWord() {
    if (_gameWords.isEmpty) {
      setState(() {
        _isGameComplete = true;
      });
      Provider.of<ProgressProvider>(context, listen: false)
          .updateGameScore(2, _score);
      return;
    }

    setState(() {
      _currentWord = _gameWords.removeAt(0);
      _shuffledLetters = List.from(_currentWord!.letters);
      _shuffledLetters.shuffle();
      _selectedLetters = [];
    });
  }

  void _onLetterTap(String letter) {
    if (_selectedLetters.length >= _currentWord!.letters.length) return;

    setState(() {
      _selectedLetters.add(letter);
      _shuffledLetters.removeAt(_shuffledLetters.indexOf(letter));
    });

    // التحقق من اكتمال الكلمة
    if (_selectedLetters.length == _currentWord!.letters.length) {
      _checkWord();
    }
  }

  void _removeLetter() {
    if (_selectedLetters.isEmpty) return;
    final letter = _selectedLetters.removeLast();
    setState(() {
      _shuffledLetters.add(letter);
    });
  }

  void _checkWord() {
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final progress = Provider.of<ProgressProvider>(context, listen: false);
    final language = Provider.of<LanguageProvider>(context, listen: false);

    final wordText = _selectedLetters.join('');
    final isCorrect = wordText == _currentWord!.arabic || 
                       wordText == _currentWord!.english;

    if (isCorrect) {
      setState(() {
        _score += 10;
        _completedWords++;
        progress.addStars(2);
      });
      audio.playSuccess();
      
      // نطق الكلمة
      if (language.isArabic) {
        audio.speakArabic(_currentWord!.arabic);
      } else {
        audio.speakEnglish(_currentWord!.english);
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _nextWord();
        }
      });
    } else {
      audio.playWrong();
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ حاول مرة أخرى!'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isArabic = language.isArabic;

    if (_currentWord == null && !_isGameComplete) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isArabic ? '🧩 بناء الكلمة' : '🧩 Word Builder'),
        backgroundColor: AppColors.accent,
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
      body: _isGameComplete
          ? _buildCompletionScreen(context)
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الإيموجي
                  Text(
                    _currentWord!.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 16),
                  
                  // الكلمة المبنية
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _selectedLetters.isEmpty
                          ? [
                              Text(
                                isArabic ? '👆 اختر الحروف' : '👆 Pick letters',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                              ),
                            ]
                          : _selectedLetters.map((letter) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.accent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              );
                            }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // عدد الحروف المتبقية
                  Text(
                    isArabic
                        ? '${_selectedLetters.length}/${_currentWord!.letters.length} حروف'
                        : '${_selectedLetters.length}/${_currentWord!.letters.length} letters',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // الحروف المتاحة
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _shuffledLetters.map((letter) {
                      return GestureDetector(
                        onTap: () => _onLetterTap(letter),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // زر التراجع
                  ElevatedButton.icon(
                    onPressed: _selectedLetters.isEmpty ? null : _removeLetter,
                    icon: const Icon(Icons.undo),
                    label: Text(isArabic ? 'تراجع' : 'Undo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // التلميح
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'الكلمة من ${_currentWord!.letters.length} حروف' 
                                    : 'The word has ${_currentWord!.letters.length} letters',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ],
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'أحسنت! 🏆' : 'Good job! 🏆',
              style: AppTheme.lightTheme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'بنيت $_completedWords كلمات بشكل صحيح!'
                  : 'You built $_completedWords words correctly!',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    '$_score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _initGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    isArabic ? 'العب مرة أخرى' : 'Play Again',
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
    );
  }
}