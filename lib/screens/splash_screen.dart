import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة أو شعار
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🌙',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ).animate().scale(duration: 800.ms).then()
              .fade(duration: 500.ms),
            
            const SizedBox(height: 30),
            
            Text(
              'روضة النور',
              style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: AppColors.primary,
                fontSize: 36,
              ),
            ).animate().fade(duration: 600.ms, delay: 400.ms),
            
            const SizedBox(height: 10),
            
            Text(
              'Rawdat Al-Noor',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ).animate().fade(duration: 600.ms, delay: 600.ms),
            
            const SizedBox(height: 50),
            
            // شريط التحميل
            SizedBox(
              width: 150,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms, delay: 800.ms),
            
            const SizedBox(height: 20),
            
            Text(
              'نحن نجهز رحلتك التعليمية... 🌟',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ).animate().fade(duration: 400.ms, delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}