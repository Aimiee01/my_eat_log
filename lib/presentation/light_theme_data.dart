import 'package:flutter/material.dart';

ThemeData get lightThemeData {
  return ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(
      primary: Colors.orange,
      onPrimary: Colors.white,
      secondary: Colors.lightGreen,
      onSecondary: Colors.white,
    ),
    indicatorColor: Colors.white,
  );
}
