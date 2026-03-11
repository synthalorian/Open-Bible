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
    await VerseStorageService.initialize();
    final storageIds = VerseStorageService.getBookmarks().map((b) => b.id).toList();
    state = storageIds;
  }

  Future<void> addBookmark(String verseId) async {
    if (!state.contains(verseId)) {
      state = [...state, verseId];
    }
  }

  Future<void> removeBookmark(String verseId) async {
    state = state.where((id) => id != verseId).toList();
  }

  Future<void> clearBookmarks() async {
    state = [];
  }
  
  bool isBookmarked(String verseId) {
    return state.contains(verseId);
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
  const BibleTranslation(id: 'gen', name: 'Geneva Bible', abbreviation: 'GEN', language: 'English'),
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
}

/// Highlights provider
final highlightsProvider = StateNotifierProvider<HighlightsNotifier, Map<String, String>>((ref) => HighlightsNotifier());

class HighlightsNotifier extends StateNotifier<Map<String, String>> {
  HighlightsNotifier() : super({});

  Future<void> init() async {
    await VerseStorageService.initialize();
    final storageHighlights = VerseStorageService.getHighlights();
    final highlights = <String, String>{};
    for (final entry in storageHighlights.entries) {
      if (entry.value.highlightColor != null) {
        highlights[entry.key] = entry.value.highlightColor!;
      }
    }
    state = highlights;
  }

  Future<void> addHighlight(String verseId, String color) async {
    state = {...state, verseId: color};
  }

  Future<void> removeHighlight(String verseId) async {
    final newState = Map<String, String>.from(state);
    newState.remove(verseId);
    state = newState;
  }
}

/// Notes provider
final notesProvider = StateNotifierProvider<NotesNotifier, Map<String, String>>((ref) => NotesNotifier());

class NotesNotifier extends StateNotifier<Map<String, String>> {
  NotesNotifier() : super({});

  Future<void> init() async {
    await VerseStorageService.initialize();
    final storageNotes = VerseStorageService.getNotes();
    final notes = <String, String>{};
    for (final entry in storageNotes.entries) {
      if (entry.value.note != null) {
        notes[entry.key] = entry.value.note!;
      }
    }
    state = notes;
  }

  Future<void> addNote(String verseId, String note) async {
    state = {...state, verseId: note};
  }

  Future<void> removeNote(String verseId) async {
    final newState = Map<String, String>.from(state);
    newState.remove(verseId);
    state = newState;
  }
}

/// Bible data provider
class BibleData {
  final String translationId;
  BibleData({this.translationId = 'kjv'});
}

final bibleDataProvider = StateNotifierProvider<BibleDataNotifier, BibleData>((ref) => BibleDataNotifier());

class BibleDataNotifier extends StateNotifier<BibleData> {
  BibleDataNotifier() : super(BibleData());
  void selectTranslation(String id) {
    state = BibleData(translationId: id);
    CurrentBible.set(id);
  }
}

class PopularTranslations {
  static String getOfflineId(String id) => id;
}

/// Reading position class
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

/// Settings provider - FIX: Remove async constructor load race condition
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());

class SettingsNotifier extends StateNotifier<AppSettings> {
  bool _isLoaded = false;

  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    try {
      await VerseStorageService.initialize();
      final settings = VerseStorageService.getSettings();
      if (settings.isEmpty) {
        _isLoaded = true;
        return;
      }
      
      final modeIndex = settings['readingMode'] as int? ?? ReadingMode.day.index;
      state = state.copyWith(
        fontSize: settings['fontSize'] as int? ?? state.fontSize,
        readingMode: ReadingMode.values[modeIndex.clamp(0, ReadingMode.values.length - 1)],
        notificationsEnabled: settings['notificationsEnabled'] as bool? ?? state.notificationsEnabled,
        dailyVerseNotifications: settings['dailyVerseNotifications'] as bool? ?? state.dailyVerseNotifications,
        dailyVerseHour: settings['dailyVerseHour'] as int? ?? state.dailyVerseTime.hour,
        dailyVerseMinute: settings['dailyVerseMinute'] as int? ?? state.dailyVerseTime.minute,
        audioEnabled: settings['audioEnabled'] as bool? ?? state.audioEnabled,
        isDarkMode: modeIndex == ReadingMode.night.index || modeIndex == ReadingMode.amoled.index,
      );
      _isLoaded = true;
    } catch (_) {
      _isLoaded = true;
    }
  }

  Future<void> _save() async {
    if (!_isLoaded) return; // Prevent overwriting with defaults during load
    try {
      final settings = {
        'fontSize': state.fontSize,
        'readingMode': state.readingMode.index,
        'notificationsEnabled': state.notificationsEnabled,
        'dailyVerseNotifications': state.dailyVerseNotifications,
        'dailyVerseHour': state.dailyVerseTime.hour,
        'dailyVerseMinute': state.dailyVerseTime.minute,
        'audioEnabled': state.audioEnabled,
      };
      await VerseStorageService.saveSettings(settings);
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

  void setAudioEnabled(bool enabled) {
    state = state.copyWith(audioEnabled: enabled);
    _save();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService.instance);
final bibleDownloadManagerProvider = ChangeNotifierProvider<BibleDownloadManager>((ref) => BibleDownloadManager()..init());

class ReadingPosition {
  final String bookId;
  final int chapter;
  final int verse;
  ReadingPosition({required this.bookId, required this.chapter, this.verse = 1});
}
