import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../app_theme.dart';
import '../../providers/language_provider.dart';
import 'custom_button.dart';

/// نافذة حوار مخصصة بتصميم موحّد للتطبيق
/// تُستخدم للتأكيدات والرسائل الودية للأطفال
class CustomDialog extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  final Color color;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CustomDialog({
    super.key,
    this.icon = '🌟',
    required this.title,
    required this.message,
    this.color = AppColors.primary,
    this.confirmLabel = 'حسناً',
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
  });

  /// عرض النافذة بسهولة من أي مكان في التطبيق
  static Future<void> show(
    BuildContext context, {
    String icon = '🌟',
    required String title,
    required String message,
    Color color = AppColors.primary,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;
    return showDialog(
      context: context,
      builder: (context) => CustomDialog(
        icon: icon,
        title: title,
        message: message,
        color: color,
        confirmLabel: confirmLabel ?? (isArabic ? 'حسناً' : 'OK'),
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: CustomButton(
                      label: cancelLabel!,
                      color: Colors.grey,
                      isOutlined: true,
                      height: 48,
                      onPressed: () {
                        Navigator.pop(context);
                        onCancel?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: CustomButton(
                    label: confirmLabel,
                    color: color,
                    height: 48,
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm?.call();
                    },
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
