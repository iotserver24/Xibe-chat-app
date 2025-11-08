import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  dark,
  light,
  blue,
  purple,
  green,
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.dark;
  SharedPreferences? _prefs;

  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == AppTheme.dark || 
                         _currentTheme == AppTheme.blue || 
                         _currentTheme == AppTheme.purple || 
                         _currentTheme == AppTheme.green;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs?.getInt('appTheme') ?? AppTheme.dark.index;
    _currentTheme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _prefs?.setInt('appTheme', theme.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    // Legacy toggle for backward compatibility
    _currentTheme = _currentTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    await _prefs?.setInt('appTheme', _currentTheme.index);
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.dark:
        return _darkTheme();
      case AppTheme.light:
        return _lightTheme();
      case AppTheme.blue:
        return _blueTheme();
      case AppTheme.purple:
        return _purpleTheme();
      case AppTheme.green:
        return _greenTheme();
    }
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: const Color(0xFF10A37F),
      dividerColor: const Color(0xFF1A1A1A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10A37F),
        secondary: Color(0xFF10A37F),
        surface: Color(0xFF1A1A1A),
        surfaceVariant: Color(0xFF0A0A0A),
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color(0xFF3B82F6),
      dividerColor: const Color(0xFFE5E7EB),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF2563EB),
        surface: Color(0xFFF5F5F5),
        surfaceVariant: Color(0xFFE5E7EB),
        onSurface: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ThemeData _blueTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A1929),
      primaryColor: const Color(0xFF1E88E5),
      dividerColor: const Color(0xFF1E3A5F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1E88E5),
        secondary: Color(0xFF42A5F5),
        surface: Color(0xFF132F4C),
        surfaceVariant: Color(0xFF0F2744),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A1929),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF132F4C),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  ThemeData _purpleTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A0D2E),
      primaryColor: const Color(0xFF9C27B0),
      dividerColor: const Color(0xFF3D2459),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF9C27B0),
        secondary: Color(0xFFBA68C8),
        surface: Color(0xFF2E1A47),
        surfaceVariant: Color(0xFF25153B),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A0D2E),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2E1A47),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  ThemeData _greenTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D1F12),
      primaryColor: const Color(0xFF4CAF50),
      dividerColor: const Color(0xFF2A4F30),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50),
        secondary: Color(0xFF66BB6A),
        surface: Color(0xFF1B3A20),
        surfaceVariant: Color(0xFF152E1A),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1F12),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1B3A20),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
