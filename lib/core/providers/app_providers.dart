import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/offline_bible_service.dart';

// Global service instances - nullable to prevent crashes
StorageService? _storageService;
OfflineBibleService? _offlineBibleService;

/// Safe storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  _storageService ??= StorageService();
  return _storageService!;
});

/// Safe offline Bible service provider  
final offlineBibleServiceProvider = Provider<OfflineBibleService>((ref) {
  _offlineBibleService ??= OfflineBibleService();
  return _offlineBibleService!;
});

/// App settings state
class AppSettings {
  final bool isDarkMode;
  final int fontSize;
  
  const AppSettings({
    this.isDarkMode = false,
    this.fontSize = 18,
  });
  
  AppSettings copyWith({bool? isDarkMode, int? fontSize}) => AppSettings(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    fontSize: fontSize ?? this.fontSize,
  );
}

/// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());
  
  void toggleTheme() => state = state.copyWith(isDarkMode: !state.isDarkMode);
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

/// Selected Bible ID provider
final selectedBibleProvider = StateProvider<String>((ref) => 'kjv');

/// Current book/chapter provider
final currentReadingProvider = StateProvider<CurrentReading?>((ref) => null);

class CurrentReading {
  final String bookId;
  final String bookName;
  final int chapter;
  
  CurrentReading({
    required this.bookId,
    required this.bookName,
    required this.chapter,
  });
}
