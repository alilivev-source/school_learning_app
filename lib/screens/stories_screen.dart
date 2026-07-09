import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';
import '../services/storage_service.dart';
import '../models/story_model.dart';
import 'story_detail_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<StoryModel> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final stories = await StorageService().loadStories();
    setState(() {
      _stories = stories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final language = Provider.of<LanguageProvider>(context);

    // تصفية القصص حسب المستوى
    final availableStories = _stories
        .where((story) => story.level <= progress.currentLevel)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          language.isArabic ? '📖 القصص' : '📖 Stories',
        ),
        backgroundColor: AppColors.accent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableStories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '📚',
                        style: TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        language.isArabic
                            ? 'لا توجد قصص متاحة حالياً'
                            : 'No stories available yet',
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        language.isArabic
                            ? 'أكمل المستويات لفتح قصص جديدة'
                            : 'Complete levels to unlock new stories',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableStories.length,
                  itemBuilder: (context, index) {
                    final story = availableStories[index];
                    return _buildStoryCard(
                      story: story,
                      language: language,
                    );
                  },
                ),
    );
  }

  Widget _buildStoryCard({
    required StoryModel story,
    required LanguageProvider language,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)),
        );
      },
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
        ),
        child: Row(
          children: [
            // صورة القصة (إيموجي)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  story.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // معلومات القصة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.isArabic ? story.title : story.titleEn,
                    style: AppTheme.lightTheme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  
                  // الكلمات المفتاحية
                  Wrap(
                    spacing: 4,
                    children: (language.isArabic ? story.keyWords : story.keyWordsEn)
                        .take(4)
                        .map((word) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                word,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.accent,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  
                  // مستوى القصة وعدد الصفحات
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${story.pageCount} ${language.isArabic ? 'صفحات' : 'pages'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${language.isArabic ? 'مستوى' : 'Level'} ${story.level}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // زر القراءة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}