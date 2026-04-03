import 'package:flutter/material.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void toggleTheme() {
  themeNotifier.value =
      themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}

bool get isDarkMode => themeNotifier.value == ThemeMode.dark;
