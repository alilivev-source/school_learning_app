import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/effects_manager.dart';
import '../models/letter_model.dart';
import '../providers/progress_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/language_provider.dart';
import '../services/storage_service.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  List<LetterModel> _letters = [];
  bool _isLoading = true;
  String _selectedLanguage = 'ar';
  bool _showSuccessEffect = false;
  bool _showWrongEffect = false;
  String? _effectLetterId;

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    final arabic = await StorageService().loadArabicLetters();
    final english = await StorageService().loadEnglishLetters();
    final all = [...arabic, ...english];
    setState(() {
      _letters = all;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final audio = Provider.of<AudioProvider>(context);
    final language = Provider.of<LanguageProvider>(context);

    final filteredLetters = _letters.where((letter) {
      bool languageMatch = _selectedLanguage == 'ar' ? letter.isArabic : !letter.isArabic;
      bool levelMatch = letter.level <= progress.currentLevel;
      return languageMatch && levelMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          language.isArabic ? 'تعلم الحروف' : 'Learn Letters',
        ),
        backgroundColor: AppColors.primary,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildLanguageToggle('ar', '🇸🇦'),
                _buildLanguageToggle('en', '🇬🇧'),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredLetters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🎯', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 16),
                          Text(
                            language.isArabic
                                ? 'لا توجد حروف متاحة في هذا المستوى'
                                : 'No letters available at this level',
                            style: AppTheme.lightTheme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            language.isArabic
                                ? 'أكمل المستويات السابقة لفتح حروف جديدة'
                                : 'Complete previous levels to unlock new letters',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredLetters.length,
                      itemBuilder: (context, index) {
                        final letter = filteredLetters[index];
                        final isCompleted = progress.isLetterCompleted(letter.id);

                        return _buildLetterCard(
                          letter: letter,
                          isCompleted: isCompleted,
                          audio: audio,
                          language: language,
                          progress: progress,
                        );
                      },
                    ),
          // تأثير النجاح
          if (_showSuccessEffect && _effectLetterId != null)
            EffectsManager.getFullSuccessEffect(context),
          // تأثير الخطأ
          if (_showWrongEffect && _effectLetterId != null)
            EffectsManager.getGentleWrongEffect(context),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(String code, String flag) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _selectedLanguage == code
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Opacity(
          opacity: _selectedLanguage == code ? 1.0 : 0.5,
          child: Text(
            flag,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterCard({
    required LetterModel letter,
    required bool isCompleted,
    required AudioProvider audio,
    required LanguageProvider language,
    required ProgressProvider progress,
  }) {
    return GestureDetector(
      onTap: () async {
        if (letter.isArabic) {
          await audio.speakArabic(letter.character);
        } else {
          await audio.speakEnglish(letter.character);
        }
        
        if (!isCompleted) {
          setState(() {
            _showSuccessEffect = true;
            _effectLetterId = letter.id;
          });
          
          await audio.playSuccess();
          await audio.playClap();
          await Future.delayed(const Duration(milliseconds: 300));
          await audio.playEncouragement();
          progress.completeLetter(letter.id);
          
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showSuccessEffect = false;
                _effectLetterId = null;
              });
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted 
              ? Colors.grey.shade200 
              : letter.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted 
                ? Colors.grey 
                : letter.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              letter.character,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey : letter.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              letter.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              language.isArabic ? letter.name : letter.nameEn,
              style: TextStyle(
                fontSize: 10,
                color: isCompleted ? Colors.grey : AppColors.textSecondary,
              ),
            ),
            if (isCompleted)
              const Icon(
                Icons.check_circle,
                color: AppColors.accent,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}