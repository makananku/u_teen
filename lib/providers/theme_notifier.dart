import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  ThemeData _currentTheme = ThemeData.light();

  bool get isDarkMode => _isDarkMode;
  ThemeData get currentTheme => _currentTheme;

  ThemeNotifier() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _updateTheme();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _updateTheme();
    notifyListeners();
  }

  void _updateTheme() {
    _currentTheme = ThemeData(
      scaffoldBackgroundColor: AppTheme.getBackground(_isDarkMode),
      cardColor: AppTheme.getCard(_isDarkMode),
      primaryColor: AppTheme.getButton(_isDarkMode),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppTheme.getPrimaryText(_isDarkMode)),
        bodyMedium: TextStyle(color: AppTheme.getSecondaryText(_isDarkMode)),
      ),
      iconTheme: IconThemeData(color: AppTheme.getIcon(_isDarkMode)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.getButton(_isDarkMode),
          foregroundColor: Colors.white,
        ),
      ),
      dividerColor: AppTheme.getBorder(_isDarkMode),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppTheme.getButton(_isDarkMode),
        secondary: AppTheme.getRating(_isDarkMode),
        surface: AppTheme.getCard(_isDarkMode),
        background: AppTheme.getBackground(_isDarkMode),
        onPrimary: Colors.white,
        onSecondary: AppTheme.getPrimaryText(_isDarkMode),
        onSurface: AppTheme.getPrimaryText(_isDarkMode),
        onBackground: AppTheme.getPrimaryText(_isDarkMode),
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }
}