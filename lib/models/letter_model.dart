import 'package:flutter/material.dart';

class LetterModel {
  final String id;
  final String character;
  final String name;
  final String nameEn;
  final Map<String, String> harakat;
  final String emoji;
  final String exampleWord;
  final String exampleWordEn;
  final int level;
  final Color color;
  final bool isArabic;
  
  LetterModel({
    required this.id,
    required this.character,
    required this.name,
    required this.nameEn,
    required this.harakat,
    required this.emoji,
    required this.exampleWord,
    required this.exampleWordEn,
    required this.level,
    required this.color,
    required this.isArabic,
  });
  
  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      id: json['id'] ?? '',
      character: json['char'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      harakat: Map<String, String>.from(json['harakat'] ?? {}),
      emoji: json['emoji'] ?? '',
      exampleWord: json['exampleWord'] ?? '',
      exampleWordEn: json['exampleWordEn'] ?? '',
      level: json['level'] ?? 1,
      color: Color(int.parse(json['color']?.replaceAll('#', '0xFF') ?? '0xFFFF6B6B')),
      isArabic: json['isArabic'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'char': character,
      'name': name,
      'nameEn': nameEn,
      'harakat': harakat,
      'emoji': emoji,
      'exampleWord': exampleWord,
      'exampleWordEn': exampleWordEn,
      'level': level,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'isArabic': isArabic,
    };
  }
  
  // الحصول على الحرف مع حركة معينة
  String getCharWithHaraka(String haraka) {
    return harakat[haraka] ?? character;
  }
  
  // قائمة الحركات المتاحة
  List<String> get availableHarakat => harakat.keys.toList();
}