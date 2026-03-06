import 'package:flutter/material.dart';

/// Light theme for the app
class AppTheme {
  AppTheme._();

  // Color palette - warm, reverent tones
  static const Color _primaryColor = Color(0xFF6B4E71); // Muted purple - royalty, reverence
  static const Color _secondaryColor = Color(0xFFB8860B); // Dark goldenrod - gold, Scripture
  static const Color _accentColor = Color(0xFF2E5A4C); // Dark green - life, growth

  // Light theme colors
  static const Color _lightBackground = Color(0xFFFAF8F5); // Warm white - parchment feel
  static const Color _lightSurface = Colors.white;
  static const Color _lightText = Color(0xFF1A1A2E);
  static const Color _lightTextSecondary = Color(0xFF6B7280);

  // Dark theme colors
  static const Color _darkBackground = Color(0xFF1A1A2E);
  static const Color _darkSurface = Color(0xFF252540);
  static const Color _darkText = Color(0xFFF5F5F5);
  static const Color _darkTextSecondary = Color(0xFFB0B0C0);

  // Highlight colors for verses
  static const List<Color> highlightColors = [
    Color(0xFFFFF9C4), // Yellow - wisdom
    Color(0xFFFFCDD2), // Red - love, sacrifice
    Color(0xFFC8E6C9), // Green - life, growth
    Color(0xFFBBDEFB), // Blue - peace, heaven
    Color(0xFFE1BEE7), // Purple - royalty, majesty
    Color(0xFFFFE0B2), // Orange - passion
    Color(0xFFB2DFDB), // Teal - healing
    Color(0xFFF8BBD0), // Pink - joy
  ];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      surface: _lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightText,
    ),
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightBackground,
      foregroundColor: _lightText,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: _lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: _buildTextTheme(_lightText, _lightTextSecondary),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _lightTextSecondary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightSurface,
      selectedColor: _primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(color: _lightText),
    ),
    dividerTheme: DividerThemeData(
      color: _lightTextSecondary.withOpacity(0.2),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF9B7BA3), // Lighter purple for dark mode
      secondary: Color(0xFFD4A84B), // Lighter gold
      tertiary: Color(0xFF4A8B76), // Lighter green
      surface: _darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: _darkText,
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkText,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: _darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: _buildTextTheme(_darkText, _darkTextSecondary),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: Color(0xFF9B7BA3),
      unselectedItemColor: _darkTextSecondary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF9B7BA3),
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurface,
      selectedColor: Color(0xFF9B7BA3).withOpacity(0.3),
      labelStyle: TextStyle(color: _darkText),
    ),
    dividerTheme: DividerThemeData(
      color: _darkTextSecondary.withOpacity(0.2),
    ),
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      // Verse text - serif for readability
      bodyLarge: TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 18,
        height: 1.8,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 16,
        height: 1.7,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Merriweather',
        fontSize: 14,
        height: 1.6,
        color: secondary,
      ),
      // UI text - sans-serif
      headlineLarge: TextStyle(
        fontFamily: 'Lato',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Lato',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Lato',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Lato',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Lato',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Lato',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Lato',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Lato',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }
}
