import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';

/// Theme definitions for the app
class AppThemes {
  // Light theme colors
  static const Color _lightPrimary = Color(0xFF2196F3);
  static const Color _lightSurface = Color(0xFFFAFAFA);
  static const Color _lightBackground = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color _darkPrimary = Color(0xFF90CAF9);
  static const Color _darkSurface = Color(0xFF121212);

  /// Light theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        brightness: Brightness.light,
        surface: _lightSurface,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _lightSurface,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: _lightBackground,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
    );
  }

  /// Dark theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkPrimary,
        brightness: Brightness.dark,
        surface: _darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: _darkSurface,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
      ),
    );
  }

  /// Chart colors for light theme
  static List<Color> get lightChartColors => [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFF44336), // Red
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF795548), // Brown
  ];

  /// Chart colors for dark theme
  static List<Color> get darkChartColors => [
    const Color(0xFF90CAF9), // Light Blue
    const Color(0xFF81C784), // Light Green
    const Color(0xFFFFB74D), // Light Orange
    const Color(0xFFBA68C8), // Light Purple
    const Color(0xFFEF5350), // Light Red
    const Color(0xFF4DD0E1), // Light Cyan
    const Color(0xFFFFF176), // Light Yellow
    const Color(0xFFA1887F), // Light Brown
  ];
}

/// Theme provider that watches app settings
final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final brightness = ref.watch(platformBrightnessProvider);

  switch (settings.themeMode) {
    case AppThemeMode.light:
      return AppThemes.lightTheme;
    case AppThemeMode.dark:
      return AppThemes.darkTheme;
    case AppThemeMode.system:
      return brightness == Brightness.dark
          ? AppThemes.darkTheme
          : AppThemes.lightTheme;
  }
});

/// Dark theme provider
final darkThemeProvider = Provider<ThemeData>((ref) {
  return AppThemes.darkTheme;
});

/// Light theme provider
final lightThemeProvider = Provider<ThemeData>((ref) {
  return AppThemes.lightTheme;
});

/// Provider for current platform brightness
final platformBrightnessProvider = Provider<Brightness>((ref) {
  // This will be overridden in main.dart with actual brightness
  return Brightness.light;
});

/// Theme mode provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.themeMode.toThemeMode();
});

/// Chart colors provider that adapts to current theme
final chartColorsProvider = Provider<List<Color>>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final brightness = ref.watch(platformBrightnessProvider);

  switch (settings.themeMode) {
    case AppThemeMode.light:
      return AppThemes.lightChartColors;
    case AppThemeMode.dark:
      return AppThemes.darkChartColors;
    case AppThemeMode.system:
      return brightness == Brightness.dark
          ? AppThemes.darkChartColors
          : AppThemes.lightChartColors;
  }
});

/// Check if current theme is dark
final isDarkThemeProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final brightness = ref.watch(platformBrightnessProvider);

  switch (settings.themeMode) {
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
    case AppThemeMode.system:
      return brightness == Brightness.dark;
  }
});
