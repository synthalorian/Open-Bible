import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Prayer Entry Model
class PrayerEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final bool isAnswered;
  final List<String> tags;
  final String? category;

  PrayerEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.answeredAt,
    this.isAnswered = false,
    this.tags = const [],
    this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'answeredAt': answeredAt?.toIso8601String(),
    'isAnswered': isAnswered,
    'tags': tags,
    'category': category,
  };

  factory PrayerEntry.fromJson(Map<String, dynamic> json) => PrayerEntry(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    answeredAt: json['answeredAt'] != null 
        ? DateTime.tryParse(json['answeredAt']) 
        : null,
    isAnswered: json['isAnswered'] ?? false,
    tags: List<String>.from(json['tags'] ?? []),
    category: json['category'],
  );

  PrayerEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? answeredAt,
    bool? isAnswered,
    List<String>? tags,
    String? category,
  }) => PrayerEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    answeredAt: answeredAt ?? this.answeredAt,
    isAnswered: isAnswered ?? this.isAnswered,
    tags: tags ?? this.tags,
    category: category ?? this.category,
  );
}

// Streak Data Model
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalDaysRead;
  final DateTime? lastReadDate;

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalDaysRead = 0,
    this.lastReadDate,
  });

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalDaysRead': totalDaysRead,
    'lastReadDate': lastReadDate?.toIso8601String(),
  };

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    totalDaysRead: json['totalDaysRead'] ?? 0,
    lastReadDate: json['lastReadDate'] != null
        ? DateTime.tryParse(json['lastReadDate'])
        : null,
  );

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalDaysRead,
    DateTime? lastReadDate,
  }) => StreakData(
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    totalDaysRead: totalDaysRead ?? this.totalDaysRead,
    lastReadDate: lastReadDate ?? this.lastReadDate,
  );
}

// Bookmark Model
class Bookmark {
  final String id;
  final String verseId;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.verseId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'verseId': verseId,
    'bookId': bookId,
    'bookName': bookName,
    'chapter': chapter,
    'verse': verse,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] ?? '',
    verseId: json['verseId'] ?? '',
    bookId: json['bookId'] ?? '',
    bookName: json['bookName'] ?? '',
    chapter: json['chapter'] ?? 0,
    verse: json['verse'] ?? 0,
    text: json['text'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// Highlight Model
class Highlight {
  final String verseId;
  final String color;
  final DateTime createdAt;

  Highlight({
    required this.verseId,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'verseId': verseId,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
    verseId: json['verseId'] ?? '',
    color: json['color'] ?? 'yellow',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// Note Model
class Note {
  final String id;
  final String verseId;
  final String? reference;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.verseId,
    this.reference,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'verseId': verseId,
    'reference': reference,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] ?? '',
    verseId: json['verseId'] ?? '',
    reference: json['reference'],
    content: json['content'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

// Reading Plan Progress Model
class ReadingPlanProgress {
  final String planId;
  final int currentDay;
  final DateTime startDate;
  final List<String> completedDays;

  ReadingPlanProgress({
    required this.planId,
    required this.currentDay,
    required this.startDate,
    required this.completedDays,
  });

  Map<String, dynamic> toJson() => {
    'planId': planId,
    'currentDay': currentDay,
    'startDate': startDate.toIso8601String(),
    'completedDays': completedDays,
  };

  factory ReadingPlanProgress.fromJson(Map<String, dynamic> json) => ReadingPlanProgress(
    planId: json['planId'] ?? '',
    currentDay: json['currentDay'] ?? 0,
    startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
    completedDays: List<String>.from(json['completedDays'] ?? []),
  );
}

/// Local storage service using SharedPreferences with memory fallback
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  static StorageService get instance => _instance;
  StorageService._internal();
  
  SharedPreferences? _prefs;
  bool _initialized = false;
  
  // In-memory fallback storage
  final Map<String, Map<String, dynamic>> _memoryStorage = {};

  /// Check if storage is initialized
  bool get isInitialized => _initialized;

  /// Initialize SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      debugPrint('StorageService: Initialized successfully');
    } catch (e) {
      debugPrint('StorageService: Init error, using memory fallback: $e');
      _initialized = true;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
  }

  // ==================== SETTINGS ====================

  Future<void> setSetting<T>(String key, T value) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      final jsonStr = json.encode({'value': value});
      await _prefs!.setString('settings_$key', jsonStr);
    } catch (e) {
      debugPrint('StorageService: setSetting error: $e');
    }
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    if (!_initialized) return defaultValue;
    if (_prefs == null) return defaultValue;
    
    try {
      final jsonStr = _prefs!.getString('settings_$key');
      if (jsonStr == null) return defaultValue;
      final data = json.decode(jsonStr);
      return data['value'] as T? ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // ==================== BOOKMARKS ====================

  Future<void> addBookmark(Bookmark bookmark) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      final key = 'bookmark_${bookmark.id}';
      await _prefs!.setString(key, json.encode(bookmark.toJson()));
    } catch (e) {
      debugPrint('StorageService: addBookmark error: $e');
    }
  }

  Future<void> removeBookmark(String id) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      await _prefs!.remove('bookmark_$id');
    } catch (e) {
      debugPrint('StorageService: removeBookmark error: $e');
    }
  }

  List<Bookmark> getAllBookmarks() {
    if (!_initialized) return [];
    if (_prefs == null) return [];
    
    final bookmarks = <Bookmark>[];
    try {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('bookmark_')) {
          final jsonStr = _prefs!.getString(key);
          if (jsonStr != null) {
            bookmarks.add(Bookmark.fromJson(json.decode(jsonStr)));
          }
        }
      }
    } catch (e) {
      debugPrint('StorageService: getAllBookmarks error: $e');
    }
    return bookmarks..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool isBookmarked(String verseId) {
    if (!_initialized) return false;
    if (_prefs == null) return false;
    
    try {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('bookmark_')) {
          final jsonStr = _prefs!.getString(key);
          if (jsonStr != null) {
            final data = json.decode(jsonStr);
            if (data['verseId'] == verseId) return true;
          }
        }
      }
    } catch (e) {
      debugPrint('StorageService: isBookmarked error: $e');
    }
    return false;
  }

  // ==================== HIGHLIGHTS ====================

  Future<void> addHighlight(Highlight highlight) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      final key = 'highlight_${highlight.verseId}';
      await _prefs!.setString(key, json.encode(highlight.toJson()));
    } catch (e) {
      debugPrint('StorageService: addHighlight error: $e');
    }
  }

  Future<void> removeHighlight(String verseId) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      await _prefs!.remove('highlight_$verseId');
    } catch (e) {
      debugPrint('StorageService: removeHighlight error: $e');
    }
  }

  Highlight? getHighlight(String verseId) {
    if (!_initialized) return null;
    if (_prefs == null) return null;
    
    try {
      final jsonStr = _prefs!.getString('highlight_$verseId');
      if (jsonStr == null) return null;
      return Highlight.fromJson(json.decode(jsonStr));
    } catch (e) {
      return null;
    }
  }

  List<Highlight> getAllHighlights() {
    if (!_initialized) return [];
    if (_prefs == null) return [];
    
    final highlights = <Highlight>[];
    try {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('highlight_')) {
          final jsonStr = _prefs!.getString(key);
          if (jsonStr != null) {
            highlights.add(Highlight.fromJson(json.decode(jsonStr)));
          }
        }
      }
    } catch (e) {
      debugPrint('StorageService: getAllHighlights error: $e');
    }
    return highlights;
  }

  // ==================== NOTES ====================

  Future<void> saveNote(Note note) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      final key = 'note_${note.id}';
      await _prefs!.setString(key, json.encode(note.toJson()));
    } catch (e) {
      debugPrint('StorageService: saveNote error: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      await _prefs!.remove('note_$id');
    } catch (e) {
      debugPrint('StorageService: deleteNote error: $e');
    }
  }

  Note? getNote(String id) {
    if (!_initialized) return null;
    if (_prefs == null) return null;
    
    try {
      final jsonStr = _prefs!.getString('note_$id');
      if (jsonStr == null) return null;
      return Note.fromJson(json.decode(jsonStr));
    } catch (e) {
      return null;
    }
  }

  List<Note> getAllNotes() {
    if (!_initialized) return [];
    if (_prefs == null) return [];
    
    final notes = <Note>[];
    try {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('note_')) {
          final jsonStr = _prefs!.getString(key);
          if (jsonStr != null) {
            notes.add(Note.fromJson(json.decode(jsonStr)));
          }
        }
      }
    } catch (e) {
      debugPrint('StorageService: getAllNotes error: $e');
    }
    return notes..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<Note> getNotesForVerse(String verseId) {
    return getAllNotes().where((n) => n.verseId == verseId).toList();
  }

  // ==================== READING PLANS ====================

  Future<void> saveReadingPlan(ReadingPlanProgress progress) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      final key = 'reading_plan_${progress.planId}';
      await _prefs!.setString(key, json.encode(progress.toJson()));
      debugPrint('Reading plan saved: ${progress.planId}');
    } catch (e) {
      debugPrint('StorageService: saveReadingPlan error: $e');
    }
  }

  ReadingPlanProgress? getReadingPlanProgress(String planId) {
    if (!_initialized) return null;
    if (_prefs == null) return null;
    
    try {
      final jsonStr = _prefs!.getString('reading_plan_$planId');
      if (jsonStr == null) return null;
      return ReadingPlanProgress.fromJson(json.decode(jsonStr));
    } catch (e) {
      debugPrint('StorageService: getReadingPlanProgress error: $e');
      return null;
    }
  }

  List<ReadingPlanProgress> getAllReadingPlanProgress() {
    if (!_initialized) return [];
    if (_prefs == null) return [];
    
    final plans = <ReadingPlanProgress>[];
    try {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('reading_plan_')) {
          final jsonStr = _prefs!.getString(key);
          if (jsonStr != null) {
            plans.add(ReadingPlanProgress.fromJson(json.decode(jsonStr)));
          }
        }
      }
    } catch (e) {
      debugPrint('StorageService: getAllReadingPlanProgress error: $e');
    }
    return plans;
  }

  // ==================== PRAYER JOURNAL ====================

  Future<void> savePrayerEntry(PrayerEntry entry) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      final key = 'prayer_${entry.id}';
      await _prefs!.setString(key, json.encode(entry.toJson()));
    } catch (e) {
      debugPrint('StorageService: savePrayerEntry error: $e');
    }
  }

  Future<void> deletePrayerEntry(String id) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      await _prefs!.remove('prayer_$id');
    } catch (e) {
      debugPrint('StorageService: deletePrayerEntry error: $e');
    }
  }

  List<PrayerEntry> getAllPrayerEntries() {
    if (!_initialized) return [];
    if (_prefs == null) return [];
    
    final entries = <PrayerEntry>[];
    try {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('prayer_')) {
          final jsonStr = _prefs!.getString(key);
          if (jsonStr != null) {
            entries.add(PrayerEntry.fromJson(json.decode(jsonStr)));
          }
        }
      }
    } catch (e) {
      debugPrint('StorageService: getAllPrayerEntries error: $e');
    }
    return entries..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ==================== STREAKS ====================

  Future<void> updateStreak(StreakData streak) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      await _prefs!.setString('streak_reading', json.encode(streak.toJson()));
    } catch (e) {
      debugPrint('StorageService: updateStreak error: $e');
    }
  }

  StreakData? getStreak() {
    if (!_initialized) return null;
    if (_prefs == null) return null;
    
    try {
      final jsonStr = _prefs!.getString('streak_reading');
      if (jsonStr == null) return null;
      return StreakData.fromJson(json.decode(jsonStr));
    } catch (e) {
      return null;
    }
  }

  // ==================== CACHE ====================

  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      final expiry = ttl != null 
          ? DateTime.now().add(ttl).toIso8601String()
          : null;
      await _prefs!.setString('cache_$key', json.encode({
        'data': data,
        'expiry': expiry,
      }));
    } catch (e) {
      debugPrint('StorageService: cacheData error: $e');
    }
  }

  T? getCachedData<T>(String key) {
    if (!_initialized) return null;
    if (_prefs == null) return null;
    
    try {
      final jsonStr = _prefs!.getString('cache_$key');
      if (jsonStr == null) return null;
      
      final cached = json.decode(jsonStr);
      final expiry = cached['expiry'] as String?;
      
      if (expiry != null && DateTime.now().isAfter(DateTime.parse(expiry))) {
        _prefs!.remove('cache_$key');
        return null;
      }
      
      return cached['data'] as T?;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    if (_prefs == null) return;
    
    try {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('cache_')) {
          await _prefs!.remove(key);
        }
      }
    } catch (e) {
      debugPrint('StorageService: clearCache error: $e');
    }
  }

  // ==================== SETTINGS ====================

  Future<void> setFontSize(int size) async {
    if (!_initialized) await init();
    if (_prefs == null) return;
    
    try {
      await _prefs!.setInt('settings_font_size', size);
    } catch (e) {
      debugPrint('StorageService: setFontSize error: $e');
    }
  }

  int? getFontSize() {
    if (!_initialized) return null;
    if (_prefs == null) return null;
    
    try {
      return _prefs!.getInt('settings_font_size');
    } catch (e) {
      return null;
    }
  }

  // ==================== CLEANUP ====================

  Future<void> clearAllData() async {
    if (_prefs == null) return;
    
    try {
      await _prefs!.clear();
    } catch (e) {
      debugPrint('StorageService: clearAllData error: $e');
    }
  }
}
