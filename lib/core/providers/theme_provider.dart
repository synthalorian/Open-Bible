import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider for dark mode support
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeState {
  final bool isDarkMode;
  final ThemeMode themeMode;
  
  ThemeState({
    required this.isDarkMode,
    required this.themeMode,
  });
  
  factory ThemeState.light() => ThemeState(
    isDarkMode: false,
    themeMode: ThemeMode.light,
  );
  
  factory ThemeState.dark() => ThemeState(
    isDarkMode: true,
    themeMode: ThemeMode.dark,
  );
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState.light()) {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? ThemeState.dark() : ThemeState.light();
  }
  
  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newIsDark = !state.isDarkMode;
    await prefs.setBool('isDarkMode', newIsDark);
    state = newIsDark ? ThemeState.dark() : ThemeState.light();
  }
  
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    state = isDark ? ThemeState.dark() : ThemeState.light();
  }
}
