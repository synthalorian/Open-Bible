import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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

/// Simple storage service using SharedPreferences with memory fallback
class VerseStorageService {
  static const _bookmarksKey = 'verse_storage_bookmarks_v3';
  static const _highlightsKey = 'verse_storage_highlights_v3';
  static const _notesKey = 'verse_storage_notes_v3';
  
  static SharedPreferences? _prefs;
  static List<SavedVerse> _bookmarks = [];
  static Map<String, SavedVerse> _highlights = {};
  static Map<String, SavedVerse> _notes = {};
  static bool _initialized = false;
  static File? _backupFile;
  
  /// Initialize storage
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _backupFile = File('${dir.path}/verse_storage_backup_v3.json');
    } catch (e) {
      debugPrint('VerseStorageService: could not resolve backup path: $e');
    }

    // Restore from file first.
    await _loadFromBackupFile();

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadAllData();
      _initialized = true;
    } catch (e) {
      debugPrint('VerseStorageService: Init failed, using file/memory fallback: $e');
      _initialized = true;
    }
  }

  
  static Future<void> _loadAllData() async {
    if (_prefs == null) return;

    try {
      // Keep file-restored state as baseline; only replace when prefs has payload.
      final bookmarksJson = _prefs!.getString(_bookmarksKey);
      if (bookmarksJson != null && bookmarksJson.trim().isNotEmpty) {
        final List<dynamic> list = json.decode(bookmarksJson);
        final loaded = list.map((j) => SavedVerse.fromJson(j)).toList();
        if (loaded.isNotEmpty) _bookmarks = loaded;
      }

      final highlightsJson = _prefs!.getString(_highlightsKey);
      if (highlightsJson != null && highlightsJson.trim().isNotEmpty) {
        final Map<String, dynamic> map = json.decode(highlightsJson);
        final loaded = map.map((k, v) => MapEntry(k, SavedVerse.fromJson(v)));
        if (loaded.isNotEmpty) _highlights = loaded;
      }

      final notesJson = _prefs!.getString(_notesKey);
      if (notesJson != null && notesJson.trim().isNotEmpty) {
        final Map<String, dynamic> map = json.decode(notesJson);
        final loaded = map.map((k, v) => MapEntry(k, SavedVerse.fromJson(v)));
        if (loaded.isNotEmpty) _notes = loaded;
      }

      final hasAnyData = _bookmarks.isNotEmpty || _highlights.isNotEmpty || _notes.isNotEmpty;
      if (hasAnyData) await _saveToBackupFile();
    } catch (e) {
      debugPrint('VerseStorageService: prefs load failed, keeping file/memory data: $e');
    }
  }
  
  static Future<void> _loadFromBackupFile() async {
    try {
      final f = _backupFile;
      if (f == null || !await f.exists()) return;
      final raw = await f.readAsString();
      final map = json.decode(raw) as Map<String, dynamic>;
      final bookmarks = (map['bookmarks'] as List<dynamic>? ?? []);
      final highlights = (map['highlights'] as Map<String, dynamic>? ?? {});
      final notes = (map['notes'] as Map<String, dynamic>? ?? {});

      _bookmarks = bookmarks.map((j) => SavedVerse.fromJson(j as Map<String, dynamic>)).toList();
      _highlights = highlights.map((k, v) => MapEntry(k, SavedVerse.fromJson(v as Map<String, dynamic>)));
      _notes = notes.map((k, v) => MapEntry(k, SavedVerse.fromJson(v as Map<String, dynamic>)));
    } catch (e) {
      debugPrint('VerseStorageService: backup load failed: $e');
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
      };
      await f.writeAsString(json.encode(map), flush: true);
    } catch (e) {
      debugPrint('VerseStorageService: backup save failed: $e');
    }
  }

  static Future<void> _saveBookmarks() async {
    final jsonStr = json.encode(_bookmarks.map((v) => v.toJson()).toList());
    await _saveToBackupFile();
    
    try {
      if (_prefs != null) {
        await _prefs!.setString(_bookmarksKey, jsonStr);
      }
    } catch (e) {
      debugPrint('VerseStorageService: bookmark prefs write failed: $e');
    }
  }
  
  static Future<void> _saveHighlights() async {
    final jsonStr = json.encode(_highlights.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToBackupFile();

    try {
      if (_prefs != null) {
        await _prefs!.setString(_highlightsKey, jsonStr);
      }
    } catch (e) {
      debugPrint('VerseStorageService: highlight prefs write failed: $e');
    }
  }
  
  static Future<void> _saveNotes() async {
    final jsonStr = json.encode(_notes.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToBackupFile();

    try {
      if (_prefs != null) {
        await _prefs!.setString(_notesKey, jsonStr);
      }
    } catch (e) {
      debugPrint('VerseStorageService: note prefs write failed: $e');
    }
  }
  
  // Bookmarks
  static Future<void> addBookmark(SavedVerse verse) async {
    if (!_initialized) await initialize();
    _bookmarks.add(verse);
    await _saveBookmarks();
  }
  
  static Future<void> removeBookmark(String verseId) async {
    if (!_initialized) await initialize();
    _bookmarks.removeWhere((v) => v.id == verseId);
    await _saveBookmarks();
  }
  
  static Future<void> clearBookmarks() async {
    if (!_initialized) await initialize();
    _bookmarks.clear();
    await _saveBookmarks();
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
    await _saveHighlights();
  }
  
  static Future<void> removeHighlight(String verseId) async {
    if (!_initialized) await initialize();
    _highlights.remove(verseId);
    await _saveHighlights();
  }
  
  static Map<String, SavedVerse> getHighlights() {
    if (!_initialized) return {};
    return Map.unmodifiable(_highlights);
  }
  
  static SavedVerse? getHighlight(String verseId) {
    if (!_initialized) return null;
    return _highlights[verseId];
  }
  
  /// Set highlight with full verse data and range
  static Future<void> setHighlight(
    SavedVerse verse,
    String color, {
    int? start,
    int? end,
    String? selectedText,
  }) async {
    if (!_initialized) await initialize();
    _highlights[verse.id] = verse.copyWith(
      highlightColor: color,
      highlightStart: start ?? 0,
      highlightEnd: end ?? verse.text.length,
      highlightText: selectedText,
      savedAt: DateTime.now(),
    );
    await _saveHighlights();
  }
  
  // Notes
  static Future<void> addNote(SavedVerse verse) async {
    if (!_initialized) await initialize();
    _notes[verse.id] = verse;
    await _saveNotes();
  }
  
  static Future<void> removeNote(String verseId) async {
    if (!_initialized) await initialize();
    _notes.remove(verseId);
    await _saveNotes();
  }
  
  static String? getNote(String verseId) {
    if (!_initialized) return null;
    return _notes[verseId]?.note;
  }
  
  /// Get all notes
  static Map<String, SavedVerse> getNotes() {
    if (!_initialized) return {};
    return Map.unmodifiable(_notes);
  }
  
  /// Save a note with full verse data
  static Future<void> saveNote(SavedVerse verse, String noteText) async {
    if (!_initialized) await initialize();
    _notes[verse.id] = verse.copyWith(
      note: noteText,
      savedAt: DateTime.now(),
    );
    await _saveNotes();
  }
  
  /// Clear all data
  static Future<void> clearAll() async {
    if (!_initialized) await initialize();
    _bookmarks.clear();
    _highlights.clear();
    _notes.clear();
    await _saveBookmarks();
    await _saveHighlights();
    await _saveNotes();
  }
  
  /// Check if initialized
  static bool get isInitialized => _initialized;
  
  /// Debug: Get bookmarks cache
  static List<SavedVerse> get bookmarksCache => List.from(_bookmarks);
  
  /// Debug: Get highlights cache
  static Map<String, SavedVerse> get highlightsCache => Map.from(_highlights);
  
  /// Debug: Get notes cache
  static Map<String, SavedVerse> get notesCache => Map.from(_notes);
  
  /// Debug: Get storage snapshot
  static Map<String, dynamic> debugStorageSnapshot() {
    return {
      'initialized': _initialized,
      'hasPrefs': _prefs != null,
      'bookmarksCount': _bookmarks.length,
      'highlightsCount': _highlights.length,
      'notesCount': _notes.length,
    };
  }
}

/// Highlight color utilities
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
