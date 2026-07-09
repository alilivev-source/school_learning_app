import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/effects_manager.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';
import '../providers/audio_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcomeEffect = false;

  @override
  void initState() {
    super.initState();
    // تشغيل التأثير الترحيبي بعد 1 ثانية
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showWelcomeEffect = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showWelcomeEffect = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    final audio = Provider.of<AudioProvider>(context);

    // تشغيل الموسيقى الخلفية عند الدخول للشاشة الرئيسية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (audio.isMusicEnabled) {
        audio.playBackgroundMusic();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('روضة النور'),
        backgroundColor: AppColors.primary,
        actions: [
          // زر اللغة
          IconButton(
            onPressed: () {
              language.toggleLanguage();
            },
            icon: Text(
              language.isArabic ? '🇸🇦' : '🇬🇧',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          // زر الإعدادات
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings_outlined, size: 28),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // مرحباً بالطفل
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '👋',
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.isArabic ? 'مرحباً بك في' : 'Welcome to',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            Text(
                              language.isArabic ? 'روضة النور 🌟' : 'Rawdat Al-Noor 🌟',
                              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // إحصائيات سريعة
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: '⭐',
                          value: progress.totalStars.toString(),
                          label: language.isArabic ? 'النجوم' : 'Stars',
                        ),
                        _buildStatItem(
                          icon: '📚',
                          value: progress.completedLetters.length.toString(),
                          label: language.isArabic ? 'الحروف' : 'Letters',
                        ),
                        _buildStatItem(
                          icon: '🏆',
                          value: '${progress.currentLevel}/5',
                          label: language.isArabic ? 'المستوى' : 'Level',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // أزرار القائمة الرئيسية
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuItem(
                        icon: '🔤',
                        title: language.isArabic ? 'تعلم الحروف' : 'Learn Letters',
                        color: AppColors.primary,
                        onTap: () {
                          audio.playClap();
                          Navigator.pushNamed(context, '/letters');
                        },
                      ),
                      _buildMenuItem(
                        icon: '🎮',
                        title: language.isArabic ? 'الألعاب' : 'Games',
                        color: AppColors.blue,
                        onTap: () {
                          audio.playClap();
                          Navigator.pushNamed(context, '/games');
                        },
                      ),
                      _buildMenuItem(
                        icon: '📖',
                        title: language.isArabic ? 'القصص' : 'Stories',
                        color: AppColors.accent,
                        onTap: () {
                          audio.playClap();
                          Navigator.pushNamed(context, '/stories');
                        },
                      ),
                      _buildMenuItem(
                        icon: '📈',
                        title: language.isArabic ? 'المستويات' : 'Levels',
                        color: AppColors.purple,
                        onTap: () {
                          audio.playClap();
                          Navigator.pushNamed(context, '/levels');
                        },
                      ),
                      _buildMenuItem(
                        icon: '🛒',
                        title: language.isArabic ? 'المتجر' : 'Store',
                        color: Colors.amber,
                        onTap: () {
                          audio.playClap();
                          Navigator.pushNamed(context, '/rewards');
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // نص تشجيعي
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('🐼', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            language.isArabic
                                ? 'استمر في التعلم يا بطل! كل يوم تتعلم شيئاً جديداً 🌟'
                                : 'Keep learning, champion! Every day you learn something new 🌟',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // تأثير الترحيب
          if (_showWelcomeEffect)
            EffectsManager.getFullSuccessEffect(context),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}