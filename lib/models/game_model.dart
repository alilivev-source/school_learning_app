import 'package:flutter/material.dart';

/// نموذج بيانات يمثّل لعبة تعليمية داخل التطبيق
class GameModel {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String icon;
  final Color color;
  final int minLevel;

  GameModel({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.icon,
    required this.color,
    this.minLevel = 1,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleEn: json['titleEn'] ?? '',
      description: json['description'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      icon: json['icon'] ?? '🎮',
      color: Color(int.parse((json['color'] ?? '#FF6B6B').replaceFirst('#', '0xFF'))),
      minLevel: json['minLevel'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEn': titleEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'icon': icon,
      'color': '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
      'minLevel': minLevel,
    };
  }

  /// القائمة الافتراضية للألعاب المتاحة في التطبيق
  static List<GameModel> defaultGames() {
    return [
      GameModel(
        id: 'matching',
        title: 'لعبة المطابقة',
        titleEn: 'Matching Game',
        description: 'طابق الحرف الصحيح',
        descriptionEn: 'Match the correct letter',
        icon: '🎯',
        color: const Color(0xFFFF6B6B),
      ),
      GameModel(
        id: 'memory',
        title: 'لعبة الذاكرة',
        titleEn: 'Memory Game',
        description: 'اعثر على الأزواج المتطابقة',
        descriptionEn: 'Find the matching pairs',
        icon: '🃏',
        color: const Color(0xFF4A90E2),
      ),
      GameModel(
        id: 'word_builder',
        title: 'بناء الكلمة',
        titleEn: 'Word Builder',
        description: 'رتب الحروف لتكوين كلمة',
        descriptionEn: 'Arrange letters to form a word',
        icon: '🧩',
        color: const Color(0xFF6BCB77),
      ),
      GameModel(
        id: 'letter_tracing',
        title: 'تتبع الحروف',
        titleEn: 'Letter Tracing',
        description: 'تدرّب على كتابة الحروف',
        descriptionEn: 'Practice writing letters',
        icon: '✍️',
        color: const Color(0xFF9B59B6),
      ),
      GameModel(
        id: 'quiz',
        title: 'اختبار',
        titleEn: 'Quiz',
        description: 'اختبر معلوماتك',
        descriptionEn: 'Test your knowledge',
        icon: '📝',
        color: const Color(0xFFFF8E53),
      ),
    ];
  }
}
