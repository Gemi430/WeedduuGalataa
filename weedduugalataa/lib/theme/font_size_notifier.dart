import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontSizeNotifier = ValueNotifier<double>(16.0);

const Map<String, double> fontSizes = {
  'Small': 13.0,
  'Medium': 16.0,
  'Large': 19.0,
  'Extra Large': 22.0,
};

Future<void> loadFontSize() async {
  final prefs = await SharedPreferences.getInstance();
  final size = prefs.getDouble('fontSize') ?? 16.0;
  fontSizeNotifier.value = size;
}

Future<void> saveFontSize(double size) async {
  fontSizeNotifier.value = size;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('fontSize', size);
}
