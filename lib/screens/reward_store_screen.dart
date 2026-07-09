import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';

class RewardStoreScreen extends StatelessWidget {
  const RewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context);
    final language = Provider.of<LanguageProvider>(context);

    final stickers = [
      {'emoji': '🌟', 'name': 'نجمة', 'nameEn': 'Star', 'price': 10},
      {'emoji': '🌙', 'name': 'قمر', 'nameEn': 'Moon', 'price': 15},
      {'emoji': '🌈', 'name': 'قوس قزح', 'nameEn': 'Rainbow', 'price': 20},
      {'emoji': '🦄', 'name': 'يونيكورن', 'nameEn': 'Unicorn', 'price': 25},
      {'emoji': '🎈', 'name': 'بالون', 'nameEn': 'Balloon', 'price': 10},
      {'emoji': '🎀', 'name': 'وردة', 'nameEn': 'Bow', 'price': 15},
      {'emoji': '🐼', 'name': 'باندا', 'nameEn': 'Panda', 'price': 30},
      {'emoji': '🦊', 'name': 'ثعلب', 'nameEn': 'Fox', 'price': 25},
      {'emoji': '🐰', 'name': 'أرنب', 'nameEn': 'Rabbit', 'price': 20},
      {'emoji': '🐨', 'name': 'كوالا', 'nameEn': 'Koala', 'price': 30},
      {'emoji': '🦁', 'name': 'أسد', 'nameEn': 'Lion', 'price': 35},
      {'emoji': '🐧', 'name': 'بطريق', 'nameEn': 'Penguin', 'price': 25},
      {'emoji': '🎄', 'name': 'شجرة عيد', 'nameEn': 'Christmas Tree', 'price': 40},
      {'emoji': '🎃', 'name': 'يقطين', 'nameEn': 'Pumpkin', 'price': 35},
      {'emoji': '⚽', 'name': 'كرة قدم', 'nameEn': 'Football', 'price': 20},
      {'emoji': '🏀', 'name': 'كرة سلة', 'nameEn': 'Basketball', 'price': 20},
      {'emoji': '🎵', 'name': 'نوتة موسيقية', 'nameEn': 'Music Note', 'price': 15},
      {'emoji': '🎨', 'name': 'لوحة رسم', 'nameEn': 'Art Palette', 'price': 25},
      {'emoji': '🚀', 'name': 'صاروخ', 'nameEn': 'Rocket', 'price': 45},
      {'emoji': '🌍', 'name': 'كرة أرضية', 'nameEn': 'Globe', 'price': 40},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          language.isArabic ? '🛒 المتجر' : '🛒 Store',
        ),
        backgroundColor: Colors.amber,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 4),
                Text(
                  '${progress.totalStars}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: stickers.length,
          itemBuilder: (context, index) {
            final sticker = stickers[index];
            final isLocked = progress.totalStars < (sticker['price'] as int);

            return GestureDetector(
              onTap: () {
                if (!isLocked) {
                  _showPurchaseDialog(
                    context,
                    sticker,
                    progress,
                    language,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        language.isArabic
                            ? '❌ ليس لديك نجوم كافية!'
                            : '❌ Not enough stars!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLocked ? Colors.grey.shade300 : AppColors.gold,
                    width: 2,
                  ),
                  boxShadow: isLocked
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sticker['emoji'] as String,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language.isArabic
                          ? sticker['name'] as String
                          : sticker['nameEn'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? Colors.grey : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '⭐',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLocked ? Colors.grey : AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${sticker['price']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isLocked ? Colors.grey : AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (isLocked)
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    Map<String, dynamic> sticker,
    ProgressProvider progress,
    LanguageProvider language,
  ) {
    final isArabic = language.isArabic;
    final price = sticker['price'] as int;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isArabic ? '🛒 شراء الملصق' : '🛒 Purchase Sticker',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sticker['emoji'] as String,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? sticker['name'] as String : sticker['nameEn'] as String,
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⭐',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 4),
                Text(
                  '$price',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'هل أنت متأكد من شراء هذا الملصق؟'
                  : 'Are you sure you want to purchase this sticker?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // شراء الملصق وخصم النجوم
              final success = progress.spendStars(price);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? (isArabic
                            ? '🎉 تم شراء الملصق بنجاح!'
                            : '🎉 Sticker purchased successfully!')
                        : (isArabic
                            ? '❌ ليس لديك نجوم كافية!'
                            : '❌ Not enough stars!'),
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
            ),
            child: Text(isArabic ? 'شراء' : 'Purchase'),
          ),
        ],
      ),
    );
  }
}