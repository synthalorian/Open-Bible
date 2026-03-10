import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/footnote_service.dart';
import '../services/storage_service.dart' show StorageService;
import '../services/current_bible.dart';
import '../services/bible_download_manager.dart';
import '../services/verse_storage_service.dart';

// Re-export all providers
export 'theme_provider.dart';
export 'audio_bible_provider.dart';
export '../../features/streaks/data/streaks_provider.dart';
export '../../features/prayer_journal/data/prayer_journal_provider.dart';
export '../../features/concordance/data/strongs_concordance_provider.dart';
export '../../features/devotional/data/devotional_provider.dart';
export '../../features/search/data/search_provider.dart';
export '../../features/comparison/data/comparison_provider.dart';
export '../../features/reading_plans/data/reading_plan_provider.dart';
export '../../features/maps_charts/data/maps_charts_provider.dart';

/// Bookmarks provider for saving favorite verses
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<String>>((ref) => BookmarksNotifier());

class BookmarksNotifier extends StateNotifier<List<String>> {
  BookmarksNotifier() : super([]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getStringList('bookmarks') ?? [];

    await VerseStorageService.initialize();
    final storageIds = VerseStorageService.getBookmarks().map((b) => b.id).toList();

    final merged = <String>{...legacy, ...storageIds}.toList();
    state = merged;
  }

  Future<void> addBookmark(String verse) async {
    final newBookmarks = List.of(state);
    if (!newBookmarks.contains(verse)) {
      newBookmarks.add(verse);
    }
    state = newBookmarks;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('bookmarks', newBookmarks);
    } catch (_) {
      // Keep in-memory state even if plugin persistence fails.
    }
  }

  Future<void> removeBookmark(String verse) async {
    final newBookmarks = List.of(state);
    newBookmarks.remove(verse);
    state = newBookmarks;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('bookmarks', newBookmarks);
    } catch (_) {
      // Keep in-memory state even if plugin persistence fails.
    }
  }

  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', []);
    state = [];
  }
  
  bool isBookmarked(String verse) {
    return state.contains(verse);
  }
}

/// Selected Bible translation provider
final selectedTranslationProvider = StateProvider<String>((ref) => 'kjv');

/// Available Bible translations
class BibleTranslation {
  final String id;
  final String name;
  final String abbreviation;
  final String language;
  
  const BibleTranslation({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.language,
  });
}

final availableTranslations = [
  // Primary English Translations
  const BibleTranslation(id: 'kjv', name: 'King James Version', abbreviation: 'KJV', language: 'English'),
  const BibleTranslation(id: 'akjv', name: 'American King James Version', abbreviation: 'AKJV', language: 'English'),
  const BibleTranslation(id: 'asv', name: 'American Standard Version', abbreviation: 'ASV', language: 'English'),
  const BibleTranslation(id: 'web', name: 'World English Bible', abbreviation: 'WEB', language: 'English'),
  const BibleTranslation(id: 'leb', name: 'Lexham English Bible', abbreviation: 'LEB', language: 'English'),
  
  // Catholic Translations
  const BibleTranslation(id: 'drc', name: 'Douay-Rheims Challoner', abbreviation: 'DRC', language: 'English'),
  
  // Modern Translations
  const BibleTranslation(id: 'net', name: 'New English Translation', abbreviation: 'NET', language: 'English'),
  const BibleTranslation(id: 'bbe', name: 'Bible in Basic English', abbreviation: 'BBE', language: 'English'),
  
  // Literal Translations
  const BibleTranslation(id: 'litv', name: 'Literal Translation', abbreviation: 'LITV', language: 'English'),
  const BibleTranslation(id: 'ylt', name: 'Young\'s Literal Translation', abbreviation: 'YLT', language: 'English'),
  const BibleTranslation(id: 'darby', name: 'Darby Translation', abbreviation: 'DARBY', language: 'English'),
  
  // Historical Translations
  const BibleTranslation(id: 'tyndale', name: 'Tyndale Bible', abbreviation: 'TYN', language: 'English'),
  const BibleTranslation(id: 'wycliffe', name: 'Wycliffe Bible', abbreviation: 'WYC', language: 'English'),
  const BibleTranslation(id: 'gen', name: 'Geneva Bible', abbreviation: 'GEN', language: 'English'),
  
  // Other Translations
  const BibleTranslation(id: 'montgomery', name: 'Montgomery New Testament', abbreviation: 'MONT', language: 'English'),
  const BibleTranslation(id: 'murdock', name: 'Murdock Translation', abbreviation: 'MUR', language: 'English'),
  const BibleTranslation(id: 'rotherham', name: 'Rotherham Emphasized Bible', abbreviation: 'RTH', language: 'English'),
  const BibleTranslation(id: 'twentieth', name: 'Twentieth Century New Testament', abbreviation: 'TCNT', language: 'English'),
  const BibleTranslation(id: 'weymouth', name: 'Weymouth New Testament', abbreviation: 'WEY', language: 'English'),
  const BibleTranslation(id: 'worsley', name: 'Worsley New Testament', abbreviation: 'WOR', language: 'English'),
];

/// Font size provider for reading
final fontSizeProvider = StateProvider<double>((ref) => 18.0);

enum ReadingMode { day, night, sepia, amoled }

class DailyVerseTime {
  final int hour;
  final int minute;

  const DailyVerseTime({required this.hour, required this.minute});
}

/// App settings class
class AppSettings {
  final String selectedBibleId;
  final int fontSize;
  final ReadingMode readingMode;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool dailyVerseNotifications;
  final DailyVerseTime dailyVerseTime;
  final bool audioEnabled;
  final String theme;
  final double lineHeight;

  const AppSettings({
    this.selectedBibleId = 'kjv',
    this.fontSize = 18,
    this.readingMode = ReadingMode.day,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.dailyVerseNotifications = true,
    this.dailyVerseTime = const DailyVerseTime(hour: 8, minute: 0),
    this.audioEnabled = true,
    this.theme = 'system',
    this.lineHeight = 1.5,
  });

  AppSettings copyWith({
    String? selectedBibleId,
    int? fontSize,
    ReadingMode? readingMode,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? dailyVerseNotifications,
    DailyVerseTime? dailyVerseTime,
    bool? audioEnabled,
    String? theme,
    double? lineHeight,
  }) {
    return AppSettings(
      selectedBibleId: selectedBibleId ?? this.selectedBibleId,
      fontSize: fontSize ?? this.fontSize,
      readingMode: readingMode ?? this.readingMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyVerseNotifications: dailyVerseNotifications ?? this.dailyVerseNotifications,
      dailyVerseTime: dailyVerseTime ?? this.dailyVerseTime,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      theme: theme ?? this.theme,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  void setFontSize(int size) {
    // compatibility shim
  }
}

/// Highlights provider
final highlightsProvider = StateNotifierProvider<HighlightsNotifier, Map<String, String>>((ref) => HighlightsNotifier());

class HighlightsNotifier extends StateNotifier<Map<String, String>> {
  HighlightsNotifier() : super({});

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('highlight_'));
    final highlights = <String, String>{};
    for (final key in keys) {
      final verseId = key.replaceFirst('highlight_', '');
      final color = prefs.getString(key);
      if (color != null) {
        highlights[verseId] = color;
      }
    }

    await VerseStorageService.initialize();
    final storageHighlights = VerseStorageService.getHighlights();
    for (final entry in storageHighlights.entries) {
      final color = entry.value.highlightColor;
      if (color != null && color.isNotEmpty) {
        highlights[entry.key] = color;
      }
    }

    state = highlights;
  }

  Future<void> addHighlight(String verseId, String color) async {
    state = {...state, verseId: color};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('highlight_$verseId', color);
    } catch (_) {
      // Keep in-memory state even if plugin persistence fails.
    }
  }

  Future<void> removeHighlight(String verseId) async {
    final newState = Map<String, String>.from(state);
    newState.remove(verseId);
    state = newState;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('highlight_$verseId');
    } catch (_) {
      // Keep in-memory state even if plugin persistence fails.
    }
  }

  String? getHighlight(String verseId) {
    return state[verseId];
  }
}

/// Notes provider
final notesProvider = StateNotifierProvider<NotesNotifier, Map<String, String>>((ref) => NotesNotifier());

/// Footnote service provider
final footnoteServiceProvider = Provider<FootnoteService>((ref) => FootnoteService());

/// Translation info class
class TranslationInfo {
  final String id;
  final String name;
  
  const TranslationInfo({required this.id, required this.name});
}

/// Bible data class
class BibleData {
  final TranslationInfo? selectedTranslation;
  
  BibleData({TranslationInfo? selectedTranslation}) 
      : selectedTranslation = selectedTranslation ?? const TranslationInfo(id: 'kjv', name: 'King James Version');
  
  BibleData copyWith({TranslationInfo? selectedTranslation}) {
    return BibleData(selectedTranslation: selectedTranslation ?? this.selectedTranslation);
  }
}

/// Bible data provider - now with proper StateNotifier
final bibleDataProvider = StateNotifierProvider<BibleDataNotifier, BibleData>(
  (ref) => BibleDataNotifier(),
);

/// Bible data notifier with translation management
class BibleDataNotifier extends StateNotifier<BibleData> {
  BibleDataNotifier() : super(BibleData());

  void selectTranslation(String translationId) {
    final translation = availableTranslations.firstWhere(
      (t) => t.id == translationId,
      orElse: () => availableTranslations.first,
    );
    
    state = state.copyWith(
      selectedTranslation: TranslationInfo(
        id: translation.id,
        name: translation.name,
      ),
    );
    
    // Sync with global CurrentBible
    CurrentBible.set(translationId);
  }
}

/// Popular translations list
class PopularTranslations {
  static const List<String> list = ['kjv', 'asv', 'web', 'net'];
  
  static String getOfflineId(String translationId) {
    return translationId; // Same ID for now
  }
}

/// Reading position class
class ReadingPositionData {
  final String bookId;
  final int chapter;
  final int verse;
  
  ReadingPositionData({required this.bookId, required this.chapter, this.verse = 1});
  
  Map<String, dynamic> toJson() => {'bookId': bookId, 'chapter': chapter, 'verse': verse};
  factory ReadingPositionData.fromJson(Map<String, dynamic> json) => ReadingPositionData(
    bookId: json['bookId'] ?? 'GEN',
    chapter: json['chapter'] ?? 1,
    verse: json['verse'] ?? 1,
  );
  
  ReadingPositionData copyWith({String? bookId, int? chapter, int? verse}) {
    return ReadingPositionData(
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
    );
  }
  
  void updatePosition({String? bookId, int? chapter, int? verse}) {
    // Method for compatibility - actual updates use copyWith
  }
}

/// Reading position notifier
class ReadingPositionNotifier extends StateNotifier<ReadingPositionData> {
  ReadingPositionNotifier() : super(ReadingPositionData(bookId: 'GEN', chapter: 1));

  void updatePosition(ReadingPosition position) {
    state = state.copyWith(
      bookId: position.bookId,
      chapter: position.chapter,
      verse: position.verse,
    );
  }
}

/// Reading position provider
final readingPositionProvider = StateNotifierProvider<ReadingPositionNotifier, ReadingPositionData>(
  (ref) => ReadingPositionNotifier(),
);

/// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt('settings_readingMode') ?? ReadingMode.day.index;
      state = state.copyWith(
        fontSize: prefs.getInt('settings_fontSize') ?? state.fontSize,
        readingMode: ReadingMode.values[modeIndex.clamp(0, ReadingMode.values.length - 1)],
        notificationsEnabled: prefs.getBool('settings_notificationsEnabled') ?? state.notificationsEnabled,
        dailyVerseNotifications: prefs.getBool('settings_dailyVerseNotifications') ?? state.dailyVerseNotifications,
        dailyVerseTime: DailyVerseTime(
          hour: prefs.getInt('settings_dailyVerseHour') ?? state.dailyVerseTime.hour,
          minute: prefs.getInt('settings_dailyVerseMinute') ?? state.dailyVerseTime.minute,
        ),
        audioEnabled: prefs.getBool('settings_audioEnabled') ?? state.audioEnabled,
      );
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('settings_fontSize', state.fontSize);
      await prefs.setInt('settings_readingMode', state.readingMode.index);
      await prefs.setBool('settings_notificationsEnabled', state.notificationsEnabled);
      await prefs.setBool('settings_dailyVerseNotifications', state.dailyVerseNotifications);
      await prefs.setInt('settings_dailyVerseHour', state.dailyVerseTime.hour);
      await prefs.setInt('settings_dailyVerseMinute', state.dailyVerseTime.minute);
      await prefs.setBool('settings_audioEnabled', state.audioEnabled);
    } catch (_) {}
  }

  void setFontSize(int size) {
    state = state.copyWith(fontSize: size);
    _save();
  }

  void setReadingMode(ReadingMode mode) {
    state = state.copyWith(
      readingMode: mode,
      isDarkMode: mode == ReadingMode.night || mode == ReadingMode.amoled,
    );
    _save();
  }

  Future<void> toggleNotifications() async {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    await _save();
  }

  Future<void> setDailyVerseNotifications(bool enabled) async {
    state = state.copyWith(dailyVerseNotifications: enabled);
    await _save();
  }

  Future<void> setDailyVerseTime(DailyVerseTime time) async {
    state = state.copyWith(dailyVerseTime: time);
    await _save();
  }

  Future<void> setAudioEnabled(bool enabled) async {
    state = state.copyWith(audioEnabled: enabled);
    await _save();
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

/// Storage service provider - uses StorageService from storage_service.dart
final storageServiceProvider = Provider<StorageService>((ref) => StorageService.instance);

/// Bible download manager provider
final bibleDownloadManagerProvider = ChangeNotifierProvider<BibleDownloadManager>((ref) {
  final manager = BibleDownloadManager();
  manager.init();
  return manager;
});

/// ReadingPosition alias for compatibility
class ReadingPosition {
  final String bookId;
  final int chapter;
  final int verse;
  
  ReadingPosition({required this.bookId, required this.chapter, this.verse = 1});
  
  Map<String, dynamic> toJson() => {'bookId': bookId, 'chapter': chapter, 'verse': verse};
  factory ReadingPosition.fromJson(Map<String, dynamic> json) => ReadingPosition(
    bookId: json['bookId'] ?? 'GEN',
    chapter: json['chapter'] ?? 1,
    verse: json['verse'] ?? 1,
  );
}

class NotesNotifier extends StateNotifier<Map<String, String>> {
  NotesNotifier() : super({});

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('note_'));
    final notes = <String, String>{};
    for (final key in keys) {
      final verseId = key.replaceFirst('note_', '');
      final note = prefs.getString(key);
      if (note != null) {
        notes[verseId] = note;
      }
    }

    await VerseStorageService.initialize();
    final storageNotes = VerseStorageService.getNotes();
    for (final entry in storageNotes.entries) {
      final note = entry.value.note;
      if (note != null && note.isNotEmpty) {
        notes[entry.key] = note;
      }
    }

    state = notes;
  }

  Future<void> addNote(String verseId, String note) async {
    state = {...state, verseId: note};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('note_$verseId', note);
    } catch (_) {
      // Keep in-memory state even if plugin persistence fails.
    }
  }

  Future<void> removeNote(String verseId) async {
    final newState = Map<String, String>.from(state);
    newState.remove(verseId);
    state = newState;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('note_$verseId');
    } catch (_) {
      // Keep in-memory state even if plugin persistence fails.
    }
  }

  String? getNote(String verseId) {
    return state[verseId];
  }
}
