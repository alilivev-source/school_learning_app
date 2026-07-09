import 'package:flutter/material.dart';
import '../app_colors.dart';

/// عرض تقييم بالنجوم (يُستخدم في شاشات إتمام الألعاب والمستويات)
class StarRating extends StatelessWidget {
  final int rating; // من 0 إلى maxStars
  final int maxStars;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool animate;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 3,
    this.size = 40,
    this.activeColor = AppColors.gold,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final bool isActive = index < rating;
        final star = Icon(
          isActive ? Icons.star_rounded : Icons.star_border_rounded,
          color: isActive ? activeColor : inactiveColor,
          size: size,
        );

        if (!animate) return Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: star);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
            duration: Duration(milliseconds: 300 + index * 150),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.6 + (0.4 * value),
                child: star,
              );
            },
          ),
        );
      }),
    );
  }
}
