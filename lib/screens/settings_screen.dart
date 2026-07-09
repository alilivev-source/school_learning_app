import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../providers/audio_provider.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    final progress = Provider.of<ProgressProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          language.isArabic ? '⚙️ الإعدادات' : '⚙️ Settings',
        ),
        backgroundColor: AppColors.primary.withOpacity(0.8),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // قسم اللغة
            _buildSectionHeader(
              icon: '🌐',
              title: language.isArabic ? 'اللغة' : 'Language',
            ),
            _buildSettingsCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLanguageOption(
                    flag: '🇸🇦',
                    name: 'العربية',
                    isSelected: language.isArabic,
                    onTap: () => language.setLanguage('ar'),
                  ),
                  _buildLanguageOption(
                    flag: '🇬🇧',
                    name: 'English',
                    isSelected: language.isEnglish,
                    onTap: () => language.setLanguage('en'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // قسم الصوت
            _buildSectionHeader(
              icon: '🔊',
              title: language.isArabic ? 'الصوت' : 'Sound',
            ),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: '🔊',
                    title: language.isArabic ? 'الأصوات' : 'Sound Effects',
                    value: audio.isSoundEnabled,
                    onChanged: (value) => audio.toggleSound(value),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: '🎵',
                    title: language.isArabic ? 'الموسيقى' : 'Background Music',
                    value: audio.isMusicEnabled,
                    onChanged: (value) => audio.toggleMusic(value),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: '🌙',
                    title: language.isArabic ? 'الوضع الليلي' : 'Dark Mode',
                    value: settings.isDarkMode,
                    onChanged: (value) => settings.toggleDarkMode(value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // قسم التقدم
            _buildSectionHeader(
              icon: '📊',
              title: language.isArabic ? 'التقدم' : 'Progress',
            ),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: '⭐',
                    title: language.isArabic ? 'النجوم' : 'Stars',
                    value: '${progress.totalStars}',
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    icon: '🔤',
                    title: language.isArabic ? 'الحروف المتقنة' : 'Completed Letters',
                    value: '${progress.completedLetters.length}',
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    icon: '📚',
                    title: language.isArabic ? 'الكلمات المتقنة' : 'Completed Words',
                    value: '${progress.completedWords.length}',
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    icon: '🏆',
                    title: language.isArabic ? 'المستوى الحالي' : 'Current Level',
                    value: '${progress.currentLevel}/5',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // قسم الإجراءات
            _buildSectionHeader(
              icon: '🛠️',
              title: language.isArabic ? 'إجراءات' : 'Actions',
            ),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildActionTile(
                    icon: '🔄',
                    title: language.isArabic ? 'إعادة تعيين التقدم' : 'Reset Progress',
                    color: Colors.red,
                    onTap: () {
                      _showResetDialog(context, progress, language);
                    },
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: '📤',
                    title: language.isArabic ? 'مشاركة التطبيق' : 'Share App',
                    color: AppColors.blue,
                    onTap: () {
                      // مشاركة التطبيق
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // معلومات التطبيق
            Center(
              child: Column(
                children: [
                  Text(
                    'روضة النور 🌙',
                    style: AppTheme.lightTheme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 روضة النور',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
      child: child,
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoTile({
    required String icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      height: 1,
    );
  }

  void _showResetDialog(
    BuildContext context,
    ProgressProvider progress,
    LanguageProvider language,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          language.isArabic ? 'إعادة تعيين التقدم' : 'Reset Progress',
        ),
        content: Text(
          language.isArabic
              ? 'هل أنت متأكد؟ سيتم حذف كل تقدمك ولا يمكن استعادته.'
              : 'Are you sure? All your progress will be deleted and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              language.isArabic ? 'إلغاء' : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              progress.resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    language.isArabic ? 'تم إعادة تعيين التقدم' : 'Progress reset',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              language.isArabic ? 'تأكيد' : 'Confirm',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}