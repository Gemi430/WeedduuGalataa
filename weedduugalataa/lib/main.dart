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
        secondary: const Color(0xFFFFC107),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: fontSize),
        bodyLarge: TextStyle(fontSize: fontSize + 2),
        bodySmall: TextStyle(fontSize: fontSize - 2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }

  ThemeData _darkTheme(double fontSize) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A237E),
        primary: const Color(0xFF3949AB),
        secondary: const Color(0xFFFFC107),
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E2E),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: fontSize),
        bodyLarge: TextStyle(fontSize: fontSize + 2),
        bodySmall: TextStyle(fontSize: fontSize - 2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E2E),
        indicatorColor: const Color(0xFF3949AB).withValues(alpha: 0.3),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E2E),
      ),
    );
  }
}
