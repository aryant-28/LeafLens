import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/language_model.dart';
import 'screens/home_screen.dart';
import 'utils/app_localization.dart';

// App color scheme
class AppColors {
  static const Color primaryGreen = Color(0xFF1E5631); // Royal green
  static const Color lightGreen = Color(0xFF3A8651);
  static const Color beige = Color(0xFFF5F2E9);
  static const Color darkBeige = Color(0xFFE8E2D5);
  static const Color textDark = Color(0xFF2D3A35);
  static const Color textLight = Color(0xFF6C7D73);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String languageCode = prefs.getString('language_code') ?? 'en';
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageModel(languageCode),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageModel = Provider.of<LanguageModel>(context);
    
    return MaterialApp(
      title: 'LeafLens - Plant Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.beige,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryGreen,
          secondary: AppColors.lightGreen,
          surface: AppColors.beige,
          background: AppColors.beige,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textDark,
          onBackground: AppColors.textDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            side: const BorderSide(color: AppColors.primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.textDark),
          titleLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      locale: Locale(languageModel.currentLanguage),
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('mr', ''), // Marathi
      ],
      localizationsDelegates: const [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
} 