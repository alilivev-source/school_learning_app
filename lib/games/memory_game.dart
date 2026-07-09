import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/letter_model.dart';
import '../providers/audio_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';

class MemoryGame extends StatefulWidget {
  final List<LetterModel> letters;
  const MemoryGame({super.key, required this.letters});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<Map<String, dynamic>> _cards = [];
  List<int> _selectedIndexes = [];
  int _matchedPairs = 0;
  int _attempts = 0;
  int _score = 0;
  bool _isLocked = false;
  bool _isGameComplete = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    // اختيار 6 حروف عشوائية
    final shuffledLetters = List.from(widget.letters);
    shuffledLetters.shuffle();
    final selectedLetters = shuffledLetters.take(6).toList();

    // إنشاء البطاقات (زوج لكل حرف)
    final cards = <Map<String, dynamic>>[];
    for (var letter in selectedLetters) {
      cards.add({
        'id': letter.id,
        'char': letter.character,
        'emoji': letter.emoji,
        'isFlipped': false,
        'isMatched': false,
      });
      cards.add({
        'id': letter.id,
        'char': letter.character,
        'emoji': letter.emoji,
        'isFlipped': false,
        'isMatched': false,
      });
    }
    cards.shuffle();
    setState(() {
      _cards = cards;
      _matchedPairs = 0;
      _attempts = 0;
      _score = 0;
      _isGameComplete = false;
    });
  }

  void _onCardTap(int index) {
    if (_isLocked) return;
    if (_cards[index]['isFlipped'] == true) return;
    if (_cards[index]['isMatched'] == true) return;

    // قلب البطاقة
    setState(() {
      _cards[index]['isFlipped'] = true;
    });

    // إضافة إلى المختارة
    _selectedIndexes.add(index);

    // إذا تم اختيار بطاقتين
    if (_selectedIndexes.length == 2) {
      _isLocked = true;
      _attempts++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    final first = _selectedIndexes[0];
    final second = _selectedIndexes[1];
    final audio = Provider.of<AudioProvider>(context, listen: false);
    final progress = Provider.of<ProgressProvider>(context, listen: false);

    if (_cards[first]['id'] == _cards[second]['id']) {
      // تطابق
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _cards[first]['isMatched'] = true;
          _cards[second]['isMatched'] = true;
          _matchedPairs++;
          _score += 10;
          _selectedIndexes.clear();
          _isLocked = false;
          progress.addStars(2);
        });
        audio.playClap();

        if (_matchedPairs == 6) {
          setState(() {
            _isGameComplete = true;
          });
          progress.updateGameScore(1, _score);
        }
      });
    } else {
      // لا تطابق
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _cards[first]['isFlipped'] = false;
          _cards[second]['isFlipped'] = false;
          _selectedIndexes.clear();
          _isLocked = false;
        });
        audio.playWrong();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isArabic = language.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isArabic ? '🃏 لعبة الذاكرة' : '🃏 Memory Game'),
        backgroundColor: AppColors.blue,
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
                children: [
                  // معلومات اللعبة
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          icon: '🎯',
                          label: isArabic ? 'المطابقات' : 'Matches',
                          value: '$_matchedPairs/6',
                        ),
                        _buildInfoItem(
                          icon: '🔄',
                          label: isArabic ? 'المحاولات' : 'Attempts',
                          value: '$_attempts',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // شبكة البطاقات
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return GestureDetector(
                          onTap: () => _onCardTap(index),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: card['isFlipped'] || card['isMatched']
                                  ? Colors.white
                                  : AppColors.blue,
                              border: Border.all(
                                color: card['isMatched']
                                    ? Colors.green
                                    : AppColors.blue.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                if (card['isFlipped'] || card['isMatched'])
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: Center(
                              child: card['isFlipped'] || card['isMatched']
                                  ? Text(
                                      card['isMatched'] ? card['emoji'] : card['char'],
                                      style: TextStyle(
                                        fontSize: card['isMatched'] ? 32 : 28,
                                        fontWeight: FontWeight.bold,
                                        color: card['isMatched'] 
                                            ? Colors.green
                                            : AppColors.textPrimary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.question_mark,
                                      color: Colors.white,
                                      size: 28,
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

  Widget _buildInfoItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
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
                  ? 'وجدت جميع المطابقات في $_attempts محاولة!'
                  : 'You found all matches in $_attempts attempts!',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
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
                    backgroundColor: AppColors.blue,
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