import 'package:flutter/material.dart';

class AppConstants {
  // أسماء المستويات
  static const List<String> levelNames = [
    'بذرة 🌱',
    'برعم 🌿',
    'شجرة 🌳',
    'قارئ 📚',
    'متمكن 🏅',
  ];
  
  static const List<String> levelNamesEn = [
    'Seed 🌱',
    'Sprout 🌿',
    'Tree 🌳',
    'Reader 📚',
    'Master 🏅',
  ];
  
  // أيقونات المستويات
  static const List<String> levelIcons = [
    '🌱',
    '🌿',
    '🌳',
    '📚',
    '🏅',
  ];
  
  // ألوان المستويات
  static const List<Color> levelColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFF44336),
  ];
  
  // عدد الحروف في كل مستوى
  static const List<int> lettersPerLevel = [10, 18, 28, 28, 28];
  
  // عدد الكلمات في كل مستوى
  static const List<int> wordsPerLevel = [20, 30, 50, 80, 100];
  
  // عدد القصص في كل مستوى
  static const List<int> storiesPerLevel = [5, 8, 12, 15, 20];
  
  // المفاتيح المستخدمة في التخزين
  static const String keyCurrentLevel = 'current_level';
  static const String keyTotalStars = 'total_stars';
  static const String keyCompletedLetters = 'completed_letters';
  static const String keyLanguage = 'language';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyMusicEnabled = 'music_enabled';
  static const String keyDarkMode = 'dark_mode';
  static const String keyUsageTime = 'usage_time';
  static const String keyLastUsed = 'last_used';
}