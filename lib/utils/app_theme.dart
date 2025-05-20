import 'package:flutter/material.dart';

class AppTheme {
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color primaryColor = Colors.blue;

  static final ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    ),
  );

  static const EdgeInsets dialogPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}