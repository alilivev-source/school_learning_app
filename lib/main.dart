import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/levels_screen.dart';
import 'screens/letters_screen.dart';
import 'screens/games_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reward_store_screen.dart';
import 'providers/progress_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/language_provider.dart';
import 'providers/settings_provider.dart';
import 'core/app_theme.dart';
import 'core/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة التخزين المحلي
  await Hive.initFlutter();
  await Hive.openBox('progressBox');
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs),
        ),
      ],
      child: Consumer2<LanguageProvider, SettingsProvider>(
        builder: (context, languageProvider, settingsProvider, child) {
          return MaterialApp(
            title: 'روضة النور',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale?.languageCode == 'en') {
                return const Locale('en', 'US');
              }
              return const Locale('ar', 'SA');
            },
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/levels': (context) => const LevelsScreen(),
              '/letters': (context) => const LettersScreen(),
              '/games': (context) => const GamesScreen(),
              '/stories': (context) => const StoriesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/rewards': (context) => const RewardStoreScreen(),
            },
          );
        },
      ),
    );
  }
}