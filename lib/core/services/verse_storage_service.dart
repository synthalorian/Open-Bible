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
  static String _lastError = "None";
  
  /// Initialize storage
  static Future<void> initialize({bool force = false}) async {
    if (_initialized && _backupFile != null && !force) return;

    try {
      // Clear error on new attempt
      _lastError = "None";
      
      Directory? dir;
      try {
        dir = await getApplicationSupportDirectory();
      } catch (e) {
        _lastError = "SupportDir: $e";
        dir = await getApplicationDocumentsDirectory();
      }
      
      _backupFile = File('${dir.path}/verse_storage_backup_v4.json');
      
      // Migration logic
      if (!await _backupFile!.exists()) {
        try {
          final docsDir = await getApplicationDocumentsDirectory();
          final oldFile = File('${docsDir.path}/verse_storage_backup_v3.json');
          if (await oldFile.exists()) {
            await oldFile.copy(_backupFile!.path);
            debugPrint('VerseStorageService: Migrated v3 to v4');
          }
        } catch (e) {
          debugPrint('VerseStorageService: Migration failed: $e');
        }
      }
    } catch (e) {
      _lastError = "InitPath: $e";
      debugPrint('VerseStorageService: path init failed: $e');
    }

    // Load from authoritative backup file
    await _loadFromBackupFile();

    // Init SharedPreferences
    try {
      _prefs = await SharedPreferences.getInstance();
      final hasFileData = _bookmarks.isNotEmpty || _highlights.isNotEmpty || _notes.isNotEmpty;
      if (!hasFileData) {
        await _loadAllData();
        if (_bookmarks.isNotEmpty || _highlights.isNotEmpty || _notes.isNotEmpty) {
          await _saveToBackupFile();
        }
      }
    } catch (e) {
      _lastError = "Prefs: $e";
      debugPrint('VerseStorageService: prefs init failed: $e');
    }

    _initialized = true;
    debugPrint('VerseStorageService: Initialized. Bookmarks: ${_bookmarks.length}');
  }

  static Future<void> _loadAllData() async {
    if (_prefs == null) return;

    try {
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
    } catch (e) {
      _lastError = "LoadData: $e";
    }
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

  static Future<void> _saveBookmarks() async {
    final jsonStr = json.encode(_bookmarks.map((v) => v.toJson()).toList());
    await _saveToBackupFile();
    try {
      if (_prefs != null) {
        await _prefs!.setString(_bookmarksKey, jsonStr);
        await _prefs!.setStringList('bookmarks', _bookmarks.map((v) => v.id).toList());
      }
    } catch (e) { _lastError = "SavePrefs: $e"; }
  }
  
  static Future<void> _saveHighlights() async {
    final jsonStr = json.encode(_highlights.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToBackupFile();
    try {
      if (_prefs != null) await _prefs!.setString(_highlightsKey, jsonStr);
    } catch (e) { _lastError = "SavePrefsH: $e"; }
  }
  
  static Future<void> _saveNotes() async {
    final jsonStr = json.encode(_notes.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToBackupFile();
    try {
      if (_prefs != null) await _prefs!.setString(_notesKey, jsonStr);
    } catch (e) { _lastError = "SavePrefsN: $e"; }
  }
  
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
  
  static Future<void> setHighlight(SavedVerse verse, String color, {int? start, int? end, String? selectedText}) async {
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
  
  static Map<String, SavedVerse> getNotes() {
    if (!_initialized) return {};
    return Map.unmodifiable(_notes);
  }
  
  static Future<void> saveNote(SavedVerse verse, String noteText) async {
    if (!_initialized) await initialize();
    _notes[verse.id] = verse.copyWith(
      note: noteText,
      savedAt: DateTime.now(),
    );
    await _saveNotes();
  }
  
  static Future<void> clearAll() async {
    if (!_initialized) await initialize();
    _bookmarks.clear();
    _highlights.clear();
    _notes.clear();
    await _saveBookmarks();
    await _saveHighlights();
    await _saveNotes();
  }
  
  static bool get isInitialized => _initialized;
  
  static List<SavedVerse> get bookmarksCache => List.from(_bookmarks);
  static Map<String, SavedVerse> get highlightsCache => Map.from(_highlights);
  static Map<String, SavedVerse> get notesCache => Map.from(_notes);
  
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
      'lastError': _lastError,
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
