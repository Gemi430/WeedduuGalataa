import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "screens/home_screen.dart";
import "firebase_options.dart";
import "theme/theme_notifier.dart";
import "theme/font_size_notifier.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTheme();
  await loadFontSize();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const WeedduuApp());
}

class WeedduuApp extends StatelessWidget {
  const WeedduuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<double>(
          valueListenable: fontSizeNotifier,
          builder: (context, fontSize, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Weedduu Galataa",
              themeMode: mode,
              theme: _lightTheme(fontSize),
              darkTheme: _darkTheme(fontSize),
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }

  ThemeData _lightTheme(double fontSize) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A237E),
        primary: const Color(0xFF1A237E),
        secondary: const Color(0xFF1A237E),
        brightness: Brightness.light,
        surface: Colors.white,
        surfaceContainerHighest: const Color(0xFFF5F6FA),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: fontSize),
        bodyLarge: TextStyle(fontSize: fontSize + 2),
        bodySmall: TextStyle(fontSize: fontSize - 2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E))),
      ),
    );
  }

  ThemeData _darkTheme(double fontSize) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A237E),
        primary: const Color(0xFF7986CB),
        secondary: const Color(0xFF7986CB),
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E2E),
        surfaceContainerHighest: const Color(0xFF252535),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121220),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: fontSize),
        bodyLarge: TextStyle(fontSize: fontSize + 2),
        bodySmall: TextStyle(fontSize: fontSize - 2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E2E),
        indicatorColor: const Color(0xFF7986CB).withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E2E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252535),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF333350))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF333350))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7986CB))),
      ),
    );
  }
}
