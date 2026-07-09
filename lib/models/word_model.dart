import 'package:flutter/material.dart';

class WordModel {
  final String id;
  final String arabic;
  final String english;
  final String emoji;
  final List<String> letters;
  final String category;
  final String categoryEn;
  final int level;
  final List<String> syllables;
  final String sentence;
  final String sentenceEn;
  final bool isArabic;

  WordModel({
    required this.id,
    required this.arabic,
    required this.english,
    required this.emoji,
    required this.letters,
    required this.category,
    required this.categoryEn,
    required this.level,
    required this.syllables,
    required this.sentence,
    required this.sentenceEn,
    required this.isArabic,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] ?? '',
      arabic: json['arabic'] ?? '',
      english: json['english'] ?? '',
      emoji: json['emoji'] ?? '📝',
      letters: List<String>.from(json['letters'] ?? []),
      category: json['category'] ?? '',
      categoryEn: json['categoryEn'] ?? '',
      level: json['level'] ?? 1,
      syllables: List<String>.from(json['syllables'] ?? []),
      sentence: json['sentence'] ?? '',
      sentenceEn: json['sentenceEn'] ?? '',
      isArabic: json['isArabic'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'english': english,
      'emoji': emoji,
      'letters': letters,
      'category': category,
      'categoryEn': categoryEn,
      'level': level,
      'syllables': syllables,
      'sentence': sentence,
      'sentenceEn': sentenceEn,
      'isArabic': isArabic,
    };
  }

  // عدد الحروف في الكلمة
  int get letterCount => letters.length;

  // هل الكلمة مناسبة للمستوى المحدد
  bool isLevel(int level) => this.level == level;

  // الحصول على الكلمة باللغة المطلوبة
  String getWord(String language) {
    return language == 'ar' ? arabic : english;
  }

  // الحصول على الجملة باللغة المطلوبة
  String getSentence(String language) {
    return language == 'ar' ? sentence : sentenceEn;
  }
}