import 'package:flutter/material.dart';

class LevelModel {
  final int id;
  final String name;
  final String nameEn;
  final String emoji;
  final Color color;
  final String ageRange;
  final int lettersCount;
  final int wordsCount;
  final int storiesCount;
  final List<String> games;
  final int? unlockStars;
  final int? unlockLevel;
  final Map<String, dynamic> rewards;

  LevelModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.emoji,
    required this.color,
    required this.ageRange,
    required this.lettersCount,
    required this.wordsCount,
    required this.storiesCount,
    required this.games,
    this.unlockStars,
    this.unlockLevel,
    required this.rewards,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      emoji: json['emoji'] ?? '🌟',
      color: Color(int.parse(json['color']?.replaceAll('#', '0xFF') ?? '0xFF4CAF50')),
      ageRange: json['ageRange'] ?? '',
      lettersCount: json['lettersCount'] ?? 0,
      wordsCount: json['wordsCount'] ?? 0,
      storiesCount: json['storiesCount'] ?? 0,
      games: List<String>.from(json['games'] ?? []),
      unlockStars: json['unlockStars'],
      unlockLevel: json['unlockLevel'],
      rewards: json['rewards'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'emoji': emoji,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'ageRange': ageRange,
      'lettersCount': lettersCount,
      'wordsCount': wordsCount,
      'storiesCount': storiesCount,
      'games': games,
      'unlockStars': unlockStars,
      'unlockLevel': unlockLevel,
      'rewards': rewards,
    };
  }

  // الحصول على اسم المستوى باللغة المطلوبة
  String getName(String language) {
    return language == 'ar' ? name : nameEn;
  }

  // هل المستوى مغلق
  bool isLocked(int currentStars, int currentLevel) {
    if (id == 1) return false;
    if (unlockLevel != null && currentLevel < unlockLevel!) return true;
    if (unlockStars != null && currentStars < unlockStars!) return true;
    return false;
  }

  // الحصول على مكافأة المستوى
  String getRewardIcon() {
    return rewards['sticker'] ?? '🎖️';
  }

  int getRewardStars() {
    return rewards['stars'] ?? 50;
  }
}