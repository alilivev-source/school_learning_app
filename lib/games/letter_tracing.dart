import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/letter_model.dart';
import '../providers/audio_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';

class LetterTracing extends StatefulWidget {
  final List<LetterModel> letters;
  const LetterTracing({super.key, required this.letters});

  @override
  State<LetterTracing> createState() => _LetterTracingState();
}

class _LetterTracingState extends State<LetterTracing> {
  List<LetterModel> _gameLetters = [];
  LetterModel? _currentLetter;
  List<Offset> _points = [];
  List<List<Offset>> _tracedPath = [];
  int _score = 0;
  int _completedLetters = 0;
  bool _isGameComplete = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final shuffledLetters = List.from(widget.letters);
    shuffledLetters.shuffle();
    _gameLetters = shuffledLetters.take(8).toList();
    _completedLetters = 0;
    _score = 0;
    _nextLetter();
  }

  void _nextLetter() {
    if (_gameLetters.isEmpty) {
      setState(() {
        _isGameComplete = true;
      });
      Provider.of<ProgressProvider>(context, listen: false)
          .updateGameScore(3, _score);
      return;
    }

    setState(() {
      _currentLetter = _gameLetters.removeAt(0);
      _points = [];
      _tracedPath = [];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_points.isNotEmpty) {
      setState(() {
        _tracedPath.add(List.from(_points));
        _points = [];
      });
    }
  }

  void _checkTracing() {
    if (_tracedPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isArabic
                ? '✏️ ارسم الحرف أولاً!'
                : '✏️ Trace the letter first!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final audio = Provider.of<AudioProvider>(context, listen: false);
    final progress = Provider.of<ProgressProvider>(context, listen: false);

    // محاكاة للتقييم (في التطبيق الحقيقي يتم تحليل المسار)
    setState(() {
      _score += 10;
      _completedLetters++;
      progress.completeLetter(_currentLetter!.id);
    });
    
    audio.playSuccess();
    
    // نطق الحرف
    final language = Provider.of<LanguageProvider>(context, listen: false);
    if (language.isArabic) {
      audio.speakArabic(_currentLetter!.character);
    } else {
      audio.speakEnglish(_currentLetter!.character);
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nextLetter();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isArabic = language.isArabic;

    if (_currentLetter == null && !_isGameComplete) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isArabic ? '✏️ تتبع الحروف' : '✏️ Letter Tracing'),
        backgroundColor: AppColors.purple,
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
                  // الحرف المطلوب
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentLetter!.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              isArabic ? 'ارسم الحرف' : 'Trace the letter',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            Text(
                              _currentLetter!.character,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // منطقة الرسم
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.purple.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: GestureDetector(
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: CustomPaint(
                          painter: TracingPainter(
                            currentPath: _points,
                            tracedPaths: _tracedPath,
                            guideLetter: _currentLetter!.character,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // أزرار التحكم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _points = [];
                            _tracedPath = [];
                          });
                        },
                        icon: const Icon(Icons.delete),
                        label: Text(isArabic ? 'مسح' : 'Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _checkTracing,
                        icon: const Icon(Icons.check),
                        label: Text(isArabic ? 'تأكيد' : 'Check'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                        ),
                      ),
                    ],
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
                  ? 'تتبعت $_completedLetters حروفاً بشكل صحيح!'
                  : 'You traced $_completedLetters letters correctly!',
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
                    backgroundColor: AppColors.purple,
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

// مصمم الرسم المخصص
class TracingPainter extends CustomPainter {
  final List<Offset> currentPath;
  final List<List<Offset>> tracedPaths;
  final String guideLetter;

  TracingPainter({
    required this.currentPath,
    required this.tracedPaths,
    required this.guideLetter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم الحرف الدليلي (شفاف)
    final textPainter = TextPainter(
      text: TextSpan(
        text: guideLetter,
        style: TextStyle(
          fontSize: 150,
          color: Colors.grey.shade200,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // رسم المسارات السابقة
    final paint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var path in tracedPaths) {
      if (path.length > 1) {
        for (int i = 0; i < path.length - 1; i++) {
          canvas.drawLine(path[i], path[i + 1], paint);
        }
      }
    }

    // رسم المسار الحالي
    if (currentPath.length > 1) {
      for (int i = 0; i < currentPath.length - 1; i++) {
        canvas.drawLine(currentPath[i], currentPath[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) {
    return currentPath != oldDelegate.currentPath ||
           tracedPaths != oldDelegate.tracedPaths;
  }
}