import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';
import '../models/level_model.dart';
import '../services/storage_service.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  List<LevelModel> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final levels = await StorageService().loadLevels();
    setState(() {
      _levels = levels;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final language = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(language.isArabic ? 'المستويات' : 'Levels'),
        backgroundColor: AppColors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  final isLocked = level.isLocked(
                    progress.totalStars,
                    progress.currentLevel,
                  );
                  final isCompleted = progress.currentLevel > level.id;
                  final progressPercent = progress.getLevelProgress(
                    level.id,
                    [], // سيتم تمرير الحروف لاحقاً
                  );

                  return _buildLevelCard(
                    level: level,
                    isLocked: isLocked,
                    isCompleted: isCompleted,
                    progressPercent: progressPercent,
                    language: language,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildLevelCard({
    required LevelModel level,
    required bool isLocked,
    required bool isCompleted,
    required double progressPercent,
    required LanguageProvider language,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // محتوى البطاقة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // أيقونة المستوى
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: level.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      level.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // معلومات المستوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.isArabic ? level.name : level.nameEn,
                        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                          color: isLocked ? Colors.grey : level.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language.isArabic 
                            ? 'العمر: ${level.ageRange} سنوات'
                            : 'Age: ${level.ageRange} years',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      
                      // شريط التقدم
                      if (!isLocked) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            backgroundColor: Colors.grey.shade200,
                            color: level.color,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          language.isArabic
                              ? '${(progressPercent * 100).toInt()}% مكتمل'
                              : '${(progressPercent * 100).toInt()}% complete',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                      
                      // معلومات إضافية
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: '🔤',
                            text: '${level.lettersCount}',
                            color: level.color,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: '📝',
                            text: '${level.wordsCount}',
                            color: level.color,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: '📖',
                            text: '${level.storiesCount}',
                            color: level.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // حالة المستوى
                if (isLocked)
                  const Icon(
                    Icons.lock_outline,
                    size: 32,
                    color: Colors.grey,
                  )
                else if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    size: 32,
                    color: AppColors.accent,
                  )
                else
                  Icon(
                    Icons.play_circle_fill,
                    size: 32,
                    color: level.color,
                  ),
              ],
            ),
          ),
          
          // زر البدء
          if (!isLocked && !isCompleted)
            Positioned(
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: () {
                  // الذهاب إلى صفحة الحروف لهذا المستوى
                  Navigator.pushNamed(context, '/letters');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: level.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  language.isArabic ? 'ابدأ' : 'Start',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}