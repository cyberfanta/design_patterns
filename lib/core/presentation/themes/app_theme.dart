/// App Theme Configuration
///
/// PATTERN: Theme Pattern - Centralized styling configuration
/// WHERE: Core presentation layer theming
/// HOW: Defines app-wide color schemes, typography, and component styles
/// WHY: Maintains consistent visual identity and supports theming
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App theme configuration following design specifications:
/// - Mesh gradient backgrounds (green/cream)
/// - Glassmorphism components
/// - Status/Navigation bar in black
/// - Minimalist design without headers/footers
/// - No SafeArea usage as specified
class AppTheme {
  // PATTERN: Factory - Theme creation
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF2D5016),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF5F5DC),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  // Tower Defense inspired color scheme - Light
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: Color(0xFF4CAF50),
    // Tower green
    primaryContainer: Color(0xFF81C784),
    secondary: Color(0xFFF5F5DC),
    // Cream/beige
    secondaryContainer: Color(0xFFFFF8DC),
    surface: Color(0xFFFFFBFF),
    surfaceContainerHighest: Color(0xFFE8F5E8),
    onPrimary: Colors.white,
    onPrimaryContainer: Color(0xFF2D5016),
    onSecondary: Color(0xFF2D5016),
    onSurface: Color(0xFF1C1C1C),
    outline: Color(0xFF79747E),
    shadow: Color(0x1F000000),
  );

  // Tower Defense inspired color scheme - Dark
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF81C784),
    // Lighter green for dark mode
    primaryContainer: Color(0xFF4CAF50),
    secondary: Color(0xFFFFF8DC),
    // Cream remains same
    secondaryContainer: Color(0xFFF5F5DC),
    surface: Color(0xFF121212),
    surfaceContainerHighest: Color(0xFF1E1E1E),
    onPrimary: Color(0xFF2D5016),
    onPrimaryContainer: Colors.white,
    onSecondary: Color(0xFF2D5016),
    onSurface: Color(0xFFE3E3E3),
    outline: Color(0xFF938F99),
    shadow: Color(0x3F000000),
  );

  // System UI configuration
  static void configureSystemUI({required bool isDark}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        // Always black as specified
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        // Always black as specified
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.black,
      ),
    );
  }

  // Glassmorphism colors
  static const Color glassColor = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Mesh gradient colors (green/cream as specified)
  static const List<Color> meshGradientColors = [
    Color(0xFF4CAF50), // Primary green
    Color(0xFF81C784), // Light green
    Color(0xFFF5F5DC), // Cream
    Color(0xFFFFF8DC), // Light cream
    Color(0xFFE8F5E8), // Very light green
  ];

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Spacing constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
}
