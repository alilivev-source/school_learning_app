import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../models/story_model.dart';
import '../providers/audio_provider.dart';
import '../providers/language_provider.dart';

class StoryDetailScreen extends StatefulWidget {
  final StoryModel story;
  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  int _currentPage = 0;
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    final story = widget.story;
    final isArabic = language.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isArabic ? story.title : story.titleEn),
        backgroundColor: AppColors.accent,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isListening = !_isListening;
              });
              if (_isListening) {
                // بدء القراءة الصوتية للصفحة الحالية
                _readPageAloud(_currentPage, audio, isArabic);
              } else {
                audio.stopSpeaking();
              }
            },
            icon: Icon(
              _isListening ? Icons.volume_up : Icons.volume_off,
              color: _isListening ? Colors.yellow : Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // شريط التقدم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isArabic ? 'صفحة' : 'Page'} ${_currentPage + 1}/${story.pageCount}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${isArabic ? 'مستوى' : 'Level'} ${story.level}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // شريط التقدم
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / story.pageCount,
                backgroundColor: Colors.grey.shade300,
                color: AppColors.accent,
                minHeight: 6,
              ),
            ),
            
            // محتوى الصفحة
            Expanded(
              child: PageView.builder(
                itemCount: story.pageCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  if (_isListening) {
                    _readPageAloud(index, audio, isArabic);
                  }
                },
                itemBuilder: (context, index) {
                  final pageText = isArabic ? story.pages[index] : story.pages[index];
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // صورة القصة (إيموجي مؤقت)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              story.emoji,
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // نص الصفحة
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              pageText,
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.8,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: isArabic ? TextAlign.right : TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // أزرار التنقل
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر السابق
                  ElevatedButton(
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(isArabic ? 'السابق' : 'Previous'),
                  ),
                  
                  // مؤشر الصفحات
                  Row(
                    children: List.generate(
                      story.pageCount,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.accent
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  
                  // زر التالي
                  ElevatedButton(
                    onPressed: _currentPage < story.pageCount - 1
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: Text(isArabic ? 'التالي' : 'Next'),
                  ),
                ],
              ),
            ),
            
            // السؤال بعد القصة
            if (_currentPage == story.pageCount - 1) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🤔', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic ? 'هل فهمت القصة؟' : 'Did you understand the story?',
                        style: AppTheme.lightTheme.textTheme.bodyLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showQuestionsDialog(context, story, language);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                      ),
                      child: Text(isArabic ? 'اختبر فهمي' : 'Test my understanding'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _readPageAloud(int page, AudioProvider audio, bool isArabic) {
    final story = widget.story;
    final text = isArabic ? story.pages[page] : story.pages[page];
    if (isArabic) {
      audio.speakArabic(text);
    } else {
      audio.speakEnglish(text);
    }
  }

  void _showQuestionsDialog(
    BuildContext context,
    StoryModel story,
    LanguageProvider language,
  ) {
    final isArabic = language.isArabic;
    final questions = story.questions;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isArabic ? '📝 اختبار الفهم' : '📝 Comprehension Test',
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${isArabic ? q.question : q.questionEn}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        (isArabic ? q.options : q.optionsEn).length,
                        (optIndex) => RadioListTile<int>(
                          value: optIndex,
                          groupValue: null,
                          onChanged: (value) {
                            // معالجة الإجابة
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value == q.correctIndex
                                      ? (isArabic ? '✅ إجابة صحيحة!' : '✅ Correct!')
                                      : (isArabic ? '❌ حاول مرة أخرى' : '❌ Try again'),
                                ),
                                backgroundColor: value == q.correctIndex
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          },
                          title: Text(isArabic ? q.options[optIndex] : q.optionsEn[optIndex]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }
}