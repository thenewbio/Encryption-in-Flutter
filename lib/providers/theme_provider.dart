import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';

class AppThemes extends ChangeNotifier {
  static const int lightBlue = 0;
  static const int lightRed = 1;
  static const int dark = 2;
}

final themeCollection = ThemeCollection(
  themes: {
    AppThemes.lightBlue: ThemeData(primarySwatch: Colors.blue),
    AppThemes.lightRed: ThemeData(primarySwatch: Colors.red),
    AppThemes.dark: ThemeData.dark().copyWith(
        cardColor: const Color(0xff1d1d1d),
        scaffoldBackgroundColor: const Color(0xff121212)),
  },
  fallbackTheme: ThemeData.light(),
);
