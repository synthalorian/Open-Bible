import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// Saved verse model
class SavedVerse {
  final String id;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String? note;
  final String? highlightColor;
  final int? highlightStart;
  final int? highlightEnd;
  final String? highlightText;
  final DateTime savedAt;
  final String bibleId;
  
  const SavedVerse({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.note,
    this.highlightColor,
    this.highlightStart,
    this.highlightEnd,
    this.highlightText,
    required this.savedAt,
    required this.bibleId,
  });
  
  String get reference => '$bookName $chapter:$verse';
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'bookName': bookName,
    'chapter': chapter,
    'verse': verse,
    'text': text,
    'note': note,
    'highlightColor': highlightColor,
    'highlightStart': highlightStart,
    'highlightEnd': highlightEnd,
    'highlightText': highlightText,
    'savedAt': savedAt.toIso8601String(),
    'bibleId': bibleId,
  };
  
  factory SavedVerse.fromJson(Map<String, dynamic> json) => SavedVerse(
    id: json['id'] ?? '',
    bookId: json['bookId'] ?? '',
    bookName: json['bookName'] ?? '',
    chapter: json['chapter'] ?? 0,
    verse: json['verse'] ?? 0,
    text: json['text'] ?? '',
    note: json['note'],
    highlightColor: json['highlightColor'],
    highlightStart: json['highlightStart'],
    highlightEnd: json['highlightEnd'],
    highlightText: json['highlightText'],
    savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
    bibleId: json['bibleId'] ?? 'kjv',
  );
  
  SavedVerse copyWith({
    String? id,
    String? bookId,
    String? bookName,
    int? chapter,
    int? verse,
    String? text,
    String? note,
    String? highlightColor,
    int? highlightStart,
    int? highlightEnd,
    String? highlightText,
    DateTime? savedAt,
    String? bibleId,
  }) => SavedVerse(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    bookName: bookName ?? this.bookName,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    text: text ?? this.text,
    note: note ?? this.note,
    highlightColor: highlightColor ?? this.highlightColor,
    highlightStart: highlightStart ?? this.highlightStart,
    highlightEnd: highlightEnd ?? this.highlightEnd,
    highlightText: highlightText ?? this.highlightText,
    savedAt: savedAt ?? this.savedAt,
    bibleId: bibleId ?? this.bibleId,
  );
}

/// Unified storage service using local file as authority
class VerseStorageService {
  static const _bookmarksKey = 'verse_storage_bookmarks_v3';
  
  static SharedPreferences? _prefs;
  static List<SavedVerse> _bookmarks = [];
  static Map<String, SavedVerse> _highlights = {};
  static Map<String, SavedVerse> _notes = {};
  static Map<String, dynamic> _settings = {};
  static List<dynamic> _history = [];
  
  static bool _initialized = false;
  static File? _backupFile;
  static String _lastError = "None";
  
  /// Initialize storage
  static Future<void> initialize({bool force = false}) async {
    if (_initialized && _backupFile != null && !force) return;

    try {
      _lastError = "None";
      
      Directory? dir;
      try {
        dir = await getApplicationSupportDirectory();
      } catch (e) {
        dir = await getApplicationDocumentsDirectory();
      }
      
      _backupFile = File('${dir.path}/verse_storage_backup_v5.json');
      
      // Migration from v4 if exists
      if (!await _backupFile!.exists()) {
        final v4File = File('${dir.path}/verse_storage_backup_v4.json');
        if (await v4File.exists()) {
          await v4File.copy(_backupFile!.path);
          debugPrint('VerseStorageService: Migrated v4 to v5');
        }
      }
    } catch (e) {
      _lastError = "InitPath: $e";
    }

    // Load from authoritative backup file
    await _loadFromBackupFile();

    // Init SharedPreferences (Mirror/Legacy only)
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('VerseStorageService: SharedPreferences unavailable');
    }

    _initialized = true;
  }

  static Future<void> _loadFromBackupFile() async {
    try {
      final f = _backupFile;
      if (f == null || !await f.exists()) return;
      
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return;
      
      final Map<String, dynamic> map = json.decode(raw);
      
      final bookmarksJson = map['bookmarks'] as List<dynamic>? ?? [];
      final highlightsJson = map['highlights'] as Map<String, dynamic>? ?? {};
      final notesJson = map['notes'] as Map<String, dynamic>? ?? {};
      
      _bookmarks = bookmarksJson
          .map((j) => SavedVerse.fromJson(j as Map<String, dynamic>))
          .toList();
          
      _highlights = highlightsJson.map(
          (k, v) => MapEntry(k, SavedVerse.fromJson(v as Map<String, dynamic>)));
          
      _notes = notesJson.map(
          (k, v) => MapEntry(k, SavedVerse.fromJson(v as Map<String, dynamic>)));
          
      _settings = map['settings'] as Map<String, dynamic>? ?? {};
      _history = map['history'] as List<dynamic>? ?? [];
      
      debugPrint('VerseStorageService: Loaded data from file (Settings: ${_settings.length})');
    } catch (e) {
      _lastError = "LoadFile: $e";
    }
  }

  static Future<void> _saveToBackupFile() async {
    try {
      final f = _backupFile;
      if (f == null) return;
      
      final map = {
        'bookmarks': _bookmarks.map((v) => v.toJson()).toList(),
        'highlights': _highlights.map((k, v) => MapEntry(k, v.toJson())),
        'notes': _notes.map((k, v) => MapEntry(k, v.toJson())),
        'settings': _settings,
        'history': _history,
      };
      
      final jsonString = json.encode(map);
      final tmpFile = File('${f.path}.tmp');
      await tmpFile.writeAsString(jsonString, flush: true);
      
      if (await tmpFile.exists() && (await tmpFile.length()) > 0) {
        if (await f.exists()) await f.delete();
        await tmpFile.rename(f.path);
      } else {
        throw Exception('File verify failed');
      }
    } catch (e) {
      _lastError = "SaveFile: $e";
    }
  }

  // Settings
  static Map<String, dynamic> getSettings() => Map.from(_settings);
  
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    if (!_initialized) await initialize();
    _settings = Map.from(settings);
    await _saveToBackupFile();
  }

  // History
  static List<dynamic> getHistory() => List.from(_history);
  
  static Future<void> saveHistory(List<dynamic> history) async {
    if (!_initialized) await initialize();
    _history = List.from(history);
    await _saveToBackupFile();
  }

  // Bookmarks
  static Future<void> addBookmark(SavedVerse verse) async {
    if (!_initialized) await initialize();
    final exists = _bookmarks.any((v) => v.id == verse.id);
    if (!exists) {
      _bookmarks.add(verse);
      await _saveToBackupFile();
    }
  }
  
  static Future<void> removeBookmark(String verseId) async {
    if (!_initialized) await initialize();
    _bookmarks.removeWhere((v) => v.id == verseId);
    await _saveToBackupFile();
  }
  
  static List<SavedVerse> getBookmarks() {
    if (!_initialized) return [];
    return List.unmodifiable(_bookmarks);
  }
  
  static bool isBookmarked(String verseId) {
    if (!_initialized) return false;
    return _bookmarks.any((v) => v.id == verseId);
  }
  
  // Highlights
  static Future<void> addHighlight(SavedVerse verse) async {
    if (!_initialized) await initialize();
    _highlights[verse.id] = verse;
    await _saveToBackupFile();
  }
  
  static Future<void> setHighlight(SavedVerse verse, String color, {int? start, int? end, String? selectedText}) async {
    if (!_initialized) await initialize();
    _highlights[verse.id] = verse.copyWith(
      highlightColor: color,
      highlightStart: start ?? 0,
      highlightEnd: end ?? verse.text.length,
      highlightText: selectedText,
      savedAt: DateTime.now(),
    );
    await _saveToBackupFile();
  }
  
  static Future<void> removeHighlight(String verseId) async {
    if (!_initialized) await initialize();
    _highlights.remove(verseId);
    await _saveToBackupFile();
  }
  
  static Map<String, SavedVerse> getHighlights() {
    if (!_initialized) return {};
    return Map.unmodifiable(_highlights);
  }
  
  static SavedVerse? getHighlight(String verseId) {
    if (!_initialized) return null;
    return _highlights[verseId];
  }
  
  // Notes
  static Future<void> saveNote(SavedVerse verse, String noteText) async {
    if (!_initialized) await initialize();
    _notes[verse.id] = verse.copyWith(
      note: noteText,
      savedAt: DateTime.now(),
    );
    await _saveToBackupFile();
  }
  
  static Future<void> removeNote(String verseId) async {
    if (!_initialized) await initialize();
    _notes.remove(verseId);
    await _saveToBackupFile();
  }
  
  static Map<String, SavedVerse> getNotes() {
    if (!_initialized) return {};
    return Map.unmodifiable(_notes);
  }

  static String? getNote(String verseId) {
    if (!_initialized) return null;
    return _notes[verseId]?.note;
  }

  static Future<void> clearAll() async {
    if (!_initialized) await initialize();
    _bookmarks.clear();
    _highlights.clear();
    _notes.clear();
    _history.clear();
    // Keep settings? Usually user expects settings to stay even if data is wiped.
    await _saveToBackupFile();
  }

  static Future<void> forceSave() async {
    await initialize();
    await _saveToBackupFile();
  }

  static Future<String> getRawBackupJson() async {
    try {
      if (_backupFile == null || !await _backupFile!.exists()) return "File not found";
      return await _backupFile!.readAsString();
    } catch (e) {
      return "Error: $e";
    }
  }

  static Future<String> testNativeBridge() async {
    try {
      const channel = MethodChannel('openbible/platform');
      final result = await channel.invokeMethod('testNativeBridge');
      return result?.toString() ?? "Null Response";
    } catch (e) {
      return "Bridge Error: $e";
    }
  }

  static Map<String, dynamic> debugStorageSnapshot() {
    final backupPath = _backupFile?.path;
    bool backupExists = false;
    int backupBytes = 0;
    if (_backupFile != null) {
      try {
        backupExists = _backupFile!.existsSync();
        if (backupExists) backupBytes = _backupFile!.lengthSync();
      } catch (_) {}
    }

    return {
      'initialized': _initialized,
      'hasPrefs': _prefs != null,
      'backupPath': backupPath,
      'backupExists': backupExists,
      'backupBytes': backupBytes,
      'bookmarksCount': _bookmarks.length,
      'highlightsCount': _highlights.length,
      'notesCount': _notes.length,
      'settingsCount': _settings.length,
      'historyCount': _history.length,
      'lastError': _lastError,
    };
  }
  
  static bool get isInitialized => _initialized;
}

class HighlightColors {
  static const String yellow = 'yellow';
  static const String green = 'green';
  static const String blue = 'blue';
  static const String pink = 'pink';
  static const String orange = 'orange';
  static const String purple = 'purple';
  static const List<String> all = [yellow, green, blue, pink, orange, purple];
  static int getColorValue(String colorName) {
    switch (colorName) {
      case yellow: return 0xFFFFEB3B;
      case green: return 0xFF4CAF50;
      case blue: return 0xFF2196F3;
      case pink: return 0xFFE91E63;
      case orange: return 0xFFFF9800;
      case purple: return 0xFF9C27B0;
      default: return 0xFFFFEB3B;
    }
  }
}
