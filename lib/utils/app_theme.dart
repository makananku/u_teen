import 'package:flutter/material.dart';

class AppTheme {
  // Light mode colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;
  static const Color lightPrimaryText = Colors.black;
  static const Color lightSecondaryText = Colors.grey;
  static const Color lightTertiaryText = Color.fromRGBO(97, 97, 97, 1);
  static const Color lightIcon = Colors.grey;
  static const Color lightBorder = Color.fromRGBO(238, 238, 238, 1);
  static const Color lightButton = Colors.blue;
  static const Color lightRating = Colors.amber;
  static const Color lightProgressBackground = Color.fromRGBO(238, 238, 238, 1);
  static const Color lightProgressValue = Colors.amber;
  static const Color lightSnackBarError = Colors.red;
  static const Color lightSnackBarSuccess = Colors.green;
  static const Color lightDisabled = Color.fromRGBO(189, 189, 189, 1);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkPrimaryText = Colors.white;
  static const Color darkSecondaryText = Color.fromRGBO(158, 158, 158, 1);
  static const Color darkTertiaryText = Color.fromRGBO(158, 158, 158, 1);
  static const Color darkIcon = Color.fromRGBO(117, 117, 117, 1);
  static const Color darkBorder = Color.fromRGBO(97, 97, 97, 1);
  static const Color darkButton = Colors.blue;
  static const Color darkRating = Color.fromRGBO(255, 215, 0, 1);
  static const Color darkProgressBackground = Color.fromRGBO(66, 66, 66, 1);
  static const Color darkProgressValue = Color.fromRGBO(255, 215, 0, 1);
  static const Color darkSnackBarError = Colors.red;
  static const Color darkSnackBarSuccess = Colors.green;
  static const Color darkDisabled = Color.fromRGBO(97, 97, 97, 1);

  // Get colors based on dark mode
  static Color getBackground(bool isDarkMode) => isDarkMode ? darkBackground : lightBackground;
  static Color getCard(bool isDarkMode) => isDarkMode ? darkCard : lightCard;
  static Color getPrimaryText(bool isDarkMode) => isDarkMode ? darkPrimaryText : lightPrimaryText;
  static Color getSecondaryText(bool isDarkMode) => isDarkMode ? darkSecondaryText : lightSecondaryText;
  static Color getTertiaryText(bool isDarkMode) => isDarkMode ? darkTertiaryText : lightTertiaryText;
  static Color getIcon(bool isDarkMode) => isDarkMode ? darkIcon : lightIcon;
  static Color getBorder(bool isDarkMode) => isDarkMode ? darkBorder : lightBorder;
  static Color getButton(bool isDarkMode) => isDarkMode ? darkButton : lightButton;
  static Color getRating(bool isDarkMode) => isDarkMode ? darkRating : lightRating;
  static Color getProgressBackground(bool isDarkMode) => isDarkMode ? darkProgressBackground : lightProgressBackground;
  static Color getProgressValue(bool isDarkMode) => isDarkMode ? darkProgressValue : lightProgressValue;
  static Color getSnackBarError(bool isDarkMode) => isDarkMode ? darkSnackBarError : lightSnackBarError;
  static Color getSnackBarSuccess(bool isDarkMode) => isDarkMode ? darkSnackBarSuccess : lightSnackBarSuccess;
  static Color getDisabled(bool isDarkMode) => isDarkMode ? darkDisabled : lightDisabled;
}