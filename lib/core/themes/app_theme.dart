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
    cardTheme: CardThemeData(
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
      selectedColor: _primaryColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(color: _lightText),
    ),
    dividerTheme: DividerThemeData(
      color: _lightTextSecondary.withValues(alpha: 0.2),
    ),
  );

  static ThemeData get darkTheme => _buildDarkTheme(Brightness.dark, _darkBackground, _darkSurface);

  static ThemeData get amoledTheme => _buildDarkTheme(Brightness.dark, Colors.black, Colors.black);

  // Synthwave '84 theme — canonical Omarchy palette (purple, not navy)
  static const Color _synthBackground = Color(0xFF0D0221); // Deepest background / scaffold
  static const Color _synthSurface = Color(0xFF240037); // Card backgrounds, base surface
  static const Color _synthSurfaceAlt = Color(0xFF2D0047); // Slightly lighter surface
  static const Color _synthNavBackground = Color(0xFF0A011A); // App bar, sidebar, bottom nav
  static const Color _synthPrimary = Color(0xFF8F00FF); // Electric purple — main accent
  static const Color _synthSecondary = Color(0xFFFF00FF); // Hot pink — complementary accent
  static const Color _synthAccent = Color(0xFF00FFFF); // Cyan — tertiary accent
  static const Color _synthText = Color(0xFFFFFFFF); // White — primary text
  static const Color _synthTextDim = Color(0xFFC0A0D0); // Lighter purple-gray — secondary text
  static const Color _synthTextMuted = Color(0xFF663388); // Muted purple — hints, placeholders
  static const Color _synthBorder = Color(0xFF8F00FF); // Active borders (same as primary)
  static const Color _synthBorderDim = Color(0xFF4A0068); // Subtle borders
  static const Color _synthSelectedBg = Color(0xFF3A0055); // Row selection background

  static ThemeData get synthwaveTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _synthPrimary,
      secondary: _synthSecondary,
      tertiary: _synthAccent,
      surface: _synthSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _synthText,
      outline: _synthBorder,
      outlineVariant: _synthBorderDim,
      surfaceContainerHighest: _synthSurfaceAlt,
    ),
    scaffoldBackgroundColor: _synthBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: _synthNavBackground,
      foregroundColor: _synthText,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: _synthSurface,
      elevation: 2,
      shadowColor: _synthPrimary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _synthBorderDim, width: 0.5),
      ),
    ),
    textTheme: _buildTextTheme(_synthText, _synthTextDim),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _synthNavBackground,
      selectedItemColor: _synthPrimary,
      unselectedItemColor: _synthTextMuted,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _synthPrimary,
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _synthSurface,
      selectedColor: _synthPrimary.withValues(alpha: 0.3),
      labelStyle: TextStyle(color: _synthText),
      side: BorderSide(color: _synthBorderDim),
    ),
    dividerTheme: DividerThemeData(
      color: _synthBorderDim,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: _synthPrimary,
      unselectedLabelColor: _synthTextDim,
      indicatorColor: _synthPrimary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _synthSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _synthBorderDim),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _synthSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _synthSurface,
      contentTextStyle: TextStyle(color: _synthText),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _synthBorderDim),
      ),
    ),
    listTileTheme: ListTileThemeData(
      selectedColor: _synthText,
      selectedTileColor: _synthSelectedBg,
      iconColor: _synthPrimary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _synthPrimary;
        return _synthTextMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _synthPrimary.withValues(alpha: 0.5);
        return _synthBorderDim;
      }),
    ),
    iconTheme: IconThemeData(
      color: _synthText,
    ),
    primaryIconTheme: IconThemeData(
      color: _synthPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _synthSurface,
      hintStyle: TextStyle(color: _synthTextMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _synthBorderDim),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _synthBorderDim),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _synthPrimary, width: 1.5),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _synthPrimary,
      linearTrackColor: _synthBorderDim,
    ),
  );

  static ThemeData get sepiaTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      surface: const Color(0xFFF4ECD8),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF5B4636),
    ),
    scaffoldBackgroundColor: const Color(0xFFF4ECD8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF4ECD8),
      foregroundColor: Color(0xFF5B4636),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFCF5E5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: _buildTextTheme(const Color(0xFF5B4636), const Color(0xFF8C705F)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFF4ECD8),
      selectedItemColor: _primaryColor,
      unselectedItemColor: Color(0xFF8C705F),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFFCF5E5),
      selectedColor: _primaryColor.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: Color(0xFF5B4636)),
    ),
  );

  static ThemeData _buildDarkTheme(Brightness brightness, Color bg, Color surface) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF9B7BA3),
        secondary: const Color(0xFFD4A84B),
        tertiary: const Color(0xFF4A8B76),
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: _darkText,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: _darkText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: _buildTextTheme(_darkText, _darkTextSecondary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: const Color(0xFF9B7BA3),
        unselectedItemColor: _darkTextSecondary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9B7BA3),
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: const Color(0xFF9B7BA3).withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: _darkText),
      ),
      dividerTheme: DividerThemeData(
        color: _darkTextSecondary.withValues(alpha: 0.2),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      // Verse text - serif for readability
      bodyLarge: TextStyle(
        fontFamily: 'CrimsonText',
        fontSize: 18,
        height: 1.8,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'CrimsonText',
        fontSize: 16,
        height: 1.7,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontFamily: 'CrimsonText',
        fontSize: 14,
        height: 1.6,
        color: secondary,
      ),
      // UI text - sans-serif
      headlineLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }
}
