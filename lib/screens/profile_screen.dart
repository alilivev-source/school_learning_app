import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final language = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          language.isArabic ? '👤 ملفي' : '👤 Profile',
        ),
        backgroundColor: AppColors.purple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // صورة الملف الشخصي
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🌟',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // اسم الطفل
              Text(
                language.isArabic ? 'بطل الروضة' : 'Garden Champion',
                style: AppTheme.lightTheme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '⭐ ${progress.totalStars} ${language.isArabic ? 'نجمة' : 'Stars'}',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 24),
              
              // إحصائيات الملف
              _buildStatGrid(progress: progress, language: language),
              
              const SizedBox(height: 24),
              
              // الإنجازات
              _buildAchievements(progress: progress, language: language),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatGrid({
    required ProgressProvider progress,
    required LanguageProvider language,
  }) {
    final stats = [
      {
        'icon': '🔤',
        'label': language.isArabic ? 'الحروف' : 'Letters',
        'value': '${progress.completedLetters.length}',
      },
      {
        'icon': '📝',
        'label': language.isArabic ? 'الكلمات' : 'Words',
        'value': '${progress.completedWords.length}',
      },
      {
        'icon': '📖',
        'label': language.isArabic ? 'القصص' : 'Stories',
        'value': '0',
      },
      {
        'icon': '🎮',
        'label': language.isArabic ? 'الألعاب' : 'Games',
        'value': '${progress.gameScores.where((s) => s > 0).length}',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: stats.map((stat) {
        return Container(
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
          ),
          child: Column(
            children: [
              Text(stat['icon'] as String, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                stat['label'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievements({
    required ProgressProvider progress,
    required LanguageProvider language,
  }) {
    final achievements = [
      {
        'icon': '🌟',
        'title': language.isArabic ? 'النجم الأول' : 'First Star',
        'condition': progress.totalStars >= 1,
      },
      {
        'icon': '🎖️',
        'title': language.isArabic ? '10 نجوم' : '10 Stars',
        'condition': progress.totalStars >= 10,
      },
      {
        'icon': '🏆',
        'title': language.isArabic ? '50 نجمة' : '50 Stars',
        'condition': progress.totalStars >= 50,
      },
      {
        'icon': '👑',
        'title': language.isArabic ? '100 نجمة' : '100 Stars',
        'condition': progress.totalStars >= 100,
      },
      {
        'icon': '📚',
        'title': language.isArabic ? 'قارئ مبتدئ' : 'Beginner Reader',
        'condition': progress.completedLetters.length >= 10,
      },
      {
        'icon': '🏅',
        'title': language.isArabic ? 'قارئ متقدم' : 'Advanced Reader',
        'condition': progress.completedLetters.length >= 28,
      },
    ];

    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.isArabic ? '🏅 الإنجازات' : '🏅 Achievements',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          ...achievements.map((achievement) {
            final isUnlocked = achievement['condition'] as bool;
            return ListTile(
              leading: Text(
                isUnlocked ? (achievement['icon'] as String) : '🔒',
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                achievement['title'] as String,
                style: TextStyle(
                  color: isUnlocked ? AppColors.textPrimary : Colors.grey,
                  fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isUnlocked
                  ? const Icon(Icons.check_circle, color: AppColors.accent)
                  : const Icon(Icons.lock_outline, color: Colors.grey),
            );
          }).toList(),
        ],
      ),
    );
  }
}