import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/current_bible.dart';
import '../services/bible_download_manager.dart';
import '../services/verse_storage_service.dart';

// Re-export all providers
export 'audio_bible_provider.dart';
export '../../features/streaks/data/streaks_provider.dart';
export '../../features/prayer_journal/data/prayer_journal_provider.dart';
export '../../features/concordance/data/strongs_concordance_provider.dart';
export '../../features/devotional/data/devotional_provider.dart';
export '../../features/search/data/search_provider.dart';
export '../../features/comparison/data/comparison_provider.dart';
export '../../features/reading_plans/data/reading_plan_provider.dart';
export '../../features/maps_charts/data/maps_charts_provider.dart';

/// Bookmarks provider
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<String>>((ref) => BookmarksNotifier());

class BookmarksNotifier extends StateNotifier<List<String>> {
  BookmarksNotifier() : super([]);

  Future<void> init() async {
    await VerseStorageService.initialize();
    state = VerseStorageService.getBookmarks().map((b) => b.id).toList();
  }

  Future<void> addBookmark(String verseId) async {
    if (!state.contains(verseId)) state = [...state, verseId];
  }

  Future<void> removeBookmark(String verseId) async {
    state = state.where((id) => id != verseId).toList();
  }

  bool isBookmarked(String verseId) => state.contains(verseId);

  Future<void> clearBookmarks() async {
    for (final id in state) {
      await VerseStorageService.removeBookmark(id);
    }
    state = [];
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
  const BibleTranslation({required this.id, required this.name, required this.abbreviation, required this.language});
}

final availableTranslations = [
  const BibleTranslation(id: 'kjv', name: 'King James Version', abbreviation: 'KJV', language: 'English'),
  const BibleTranslation(id: 'akjv', name: 'American King James Version', abbreviation: 'AKJV', language: 'English'),
  const BibleTranslation(id: 'asv', name: 'American Standard Version', abbreviation: 'ASV', language: 'English'),
  const BibleTranslation(id: 'web', name: 'World English Bible', abbreviation: 'WEB', language: 'English'),
  const BibleTranslation(id: 'leb', name: 'Lexham English Bible', abbreviation: 'LEB', language: 'English'),
  const BibleTranslation(id: 'drc', name: 'Douay-Rheims Challoner', abbreviation: 'DRC', language: 'English'),
  const BibleTranslation(id: 'net', name: 'New English Translation', abbreviation: 'NET', language: 'English'),
  const BibleTranslation(id: 'bbe', name: 'Bible in Basic English', abbreviation: 'BBE', language: 'English'),
  const BibleTranslation(id: 'litv', name: 'Literal Translation', abbreviation: 'LITV', language: 'English'),
  const BibleTranslation(id: 'ylt', name: 'Young\'s Literal Translation', abbreviation: 'YLT', language: 'English'),
  const BibleTranslation(id: 'darby', name: 'Darby Translation', abbreviation: 'DARBY', language: 'English'),
  const BibleTranslation(id: 'tyndale', name: 'Tyndale Bible', abbreviation: 'TYN', language: 'English'),
  const BibleTranslation(id: 'wycliffe', name: 'Wycliffe Bible', abbreviation: 'WYC', language: 'English'),
  const BibleTranslation(id: 'geneva', name: 'Geneva Bible', abbreviation: 'GEN', language: 'English'),
];

final fontSizeProvider = StateProvider<double>((ref) => 18.0);
enum ReadingMode { day, night, sepia, amoled }

class DailyVerseTime {
  final int hour;
  final int minute;
  const DailyVerseTime({required this.hour, required this.minute});
}

class AppSettings {
  final String selectedBibleId;
  final int fontSize;
  final ReadingMode readingMode;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool dailyVerseNotifications;
  final DailyVerseTime dailyVerseTime;
  final bool audioEnabled;
  final bool isLoaded;

  const AppSettings({
    this.selectedBibleId = 'kjv',
    this.fontSize = 18,
    this.readingMode = ReadingMode.day,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.dailyVerseNotifications = true,
    this.dailyVerseTime = const DailyVerseTime(hour: 8, minute: 0),
    this.audioEnabled = true,
    this.isLoaded = false,
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
    bool? isLoaded,
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
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

/// Bible data class for ChapterReader compatibility
class TranslationInfo {
  final String id;
  final String name;
  const TranslationInfo({required this.id, required this.name});
}

class BibleData {
  final TranslationInfo? selectedTranslation;
  BibleData({this.selectedTranslation});
}

final bibleDataProvider = StateNotifierProvider<BibleDataNotifier, BibleData>((ref) => BibleDataNotifier());

class BibleDataNotifier extends StateNotifier<BibleData> {
  BibleDataNotifier() : super(BibleData(selectedTranslation: const TranslationInfo(id: 'kjv', name: 'King James Version')));
  void selectTranslation(String id) {
    final t = availableTranslations.firstWhere((t) => t.id == id, orElse: () => availableTranslations.first);
    state = BibleData(selectedTranslation: TranslationInfo(id: t.id, name: t.name));
    CurrentBible.set(id);
  }
}

class PopularTranslations {
  static String getOfflineId(String id) => id;
}

class ReadingPositionData {
  final String bookId;
  final int chapter;
  final int verse;
  ReadingPositionData({this.bookId = 'GEN', this.chapter = 1, this.verse = 1});
  ReadingPositionData copyWith({String? bookId, int? chapter, int? verse}) {
    return ReadingPositionData(bookId: bookId ?? this.bookId, chapter: chapter ?? this.chapter, verse: verse ?? this.verse);
  }
}

final readingPositionProvider = StateNotifierProvider<ReadingPositionNotifier, ReadingPositionData>((ref) => ReadingPositionNotifier());

class ReadingPositionNotifier extends StateNotifier<ReadingPositionData> {
  ReadingPositionNotifier() : super(ReadingPositionData());
  void updatePosition(ReadingPosition position) {
    state = state.copyWith(bookId: position.bookId, chapter: position.chapter, verse: position.verse);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());

class SettingsNotifier extends StateNotifier<AppSettings> {
  bool _isLoaded = false;
  SettingsNotifier() : super(const AppSettings()) { _load(); }

  Future<void> _load() async {
    try {
      await VerseStorageService.initialize();
      final s = VerseStorageService.getSettings();
      if (s.isEmpty) { 
        // Force a microtask delay to ensure UI listeners are registered before state change
        await Future.microtask(() {});
        _isLoaded = true;
        state = state.copyWith(isLoaded: true);
        return; 
      }
      final modeIndex = s['readingMode'] as int? ?? ReadingMode.day.index;
      final savedBibleId = s['selectedBibleId'] as String? ?? state.selectedBibleId;
      
      // Mirror the state update but ensure isLoaded triggers last
      final newState = state.copyWith(
        fontSize: s['fontSize'] as int? ?? state.fontSize,
        readingMode: ReadingMode.values[modeIndex.clamp(0, ReadingMode.values.length - 1)],
        notificationsEnabled: s['notificationsEnabled'] as bool? ?? state.notificationsEnabled,
        dailyVerseNotifications: s['dailyVerseNotifications'] as bool? ?? state.dailyVerseNotifications,
        dailyVerseTime: DailyVerseTime(hour: s['dailyVerseHour'] as int? ?? 8, minute: s['dailyVerseMinute'] as int? ?? 0),
        audioEnabled: s['audioEnabled'] as bool? ?? state.audioEnabled,
        isDarkMode: modeIndex == ReadingMode.night.index || modeIndex == ReadingMode.amoled.index,
        selectedBibleId: savedBibleId,
      );
      
      await Future.microtask(() {});
      CurrentBible.set(savedBibleId);
      state = newState.copyWith(isLoaded: true);
      _isLoaded = true;
    } catch (e) { 
      debugPrint('Failed to load app settings: $e');
      await Future.microtask(() {});
      _isLoaded = true;
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> _save() async {
    if (!_isLoaded) return;
    try {
      final s = {
        'fontSize': state.fontSize,
        'readingMode': state.readingMode.index,
        'notificationsEnabled': state.notificationsEnabled,
        'dailyVerseNotifications': state.dailyVerseNotifications,
        'dailyVerseHour': state.dailyVerseTime.hour,
        'dailyVerseMinute': state.dailyVerseTime.minute,
        'audioEnabled': state.audioEnabled,
        'selectedBibleId': state.selectedBibleId,
      };
      await VerseStorageService.saveSettings(s);
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  void setFontSize(int size) { state = state.copyWith(fontSize: size); _save(); }
  void setReadingMode(ReadingMode mode) { state = state.copyWith(readingMode: mode, isDarkMode: mode == ReadingMode.night || mode == ReadingMode.amoled); _save(); }
  void setAudioEnabled(bool enabled) { state = state.copyWith(audioEnabled: enabled); _save(); }
  Future<void> toggleNotifications() async { state = state.copyWith(notificationsEnabled: !state.notificationsEnabled); await _save(); }
  Future<void> setDailyVerseTime(DailyVerseTime time) async { state = state.copyWith(dailyVerseTime: time); await _save(); }
  Future<void> setDailyVerseNotifications(bool enabled) async { state = state.copyWith(dailyVerseNotifications: enabled); await _save(); }
}

final bibleDownloadManagerProvider = ChangeNotifierProvider<BibleDownloadManager>((ref) => BibleDownloadManager()..init());

class ReadingPosition {
  final String bookId;
  final int chapter;
  final int verse;
  ReadingPosition({required this.bookId, required this.chapter, this.verse = 1});
}

final highlightsProvider = StateNotifierProvider<HighlightsNotifier, Map<String, String>>((ref) => HighlightsNotifier());
class HighlightsNotifier extends StateNotifier<Map<String, String>> {
  HighlightsNotifier() : super({});
  Future<void> init() async {
    await VerseStorageService.initialize();
    final highlights = <String, String>{};
    for (final entry in VerseStorageService.getHighlights().entries) {
      if (entry.value.highlightColor != null) highlights[entry.key] = entry.value.highlightColor!;
    }
    state = highlights;
  }
  Future<void> addHighlight(String id, String color) async { state = {...state, id: color}; }
  Future<void> removeHighlight(String id) async { final n = Map<String, String>.from(state); n.remove(id); state = n; }
}

final notesProvider = StateNotifierProvider<NotesNotifier, Map<String, String>>((ref) => NotesNotifier());
class NotesNotifier extends StateNotifier<Map<String, String>> {
  NotesNotifier() : super({});
  Future<void> init() async {
    await VerseStorageService.initialize();
    final notes = <String, String>{};
    for (final entry in VerseStorageService.getNotes().entries) {
      if (entry.value.note != null) notes[entry.key] = entry.value.note!;
    }
    state = notes;
  }
  Future<void> addNote(String id, String note) async { state = {...state, id: note}; }
  Future<void> removeNote(String id) async { final n = Map<String, String>.from(state); n.remove(id); state = n; }
}
