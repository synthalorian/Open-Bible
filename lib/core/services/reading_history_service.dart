import 'dart:convert';
import 'package:hive/hive.dart';

/// Reading history entry
class HistoryEntry {
  final String bookId;
  final String bookName;
  final int chapter;
  final String bibleId;
  final DateTime readAt;
  
  const HistoryEntry({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.bibleId,
    required this.readAt,
  });
  
  String get reference => '$bookName $chapter';
  
  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookName': bookName,
    'chapter': chapter,
    'bibleId': bibleId,
    'readAt': readAt.toIso8601String(),
  };
  
  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    bookId: json['bookId'] ?? '',
    bookName: json['bookName'] ?? '',
    chapter: json['chapter'] ?? 0,
    bibleId: json['bibleId'] ?? 'kjv',
    readAt: DateTime.tryParse(json['readAt'] ?? '') ?? DateTime.now(),
  );
}

/// Service for tracking reading history using Hive
class ReadingHistoryService {
  static const _historyKey = 'reading_history';
  static const _maxHistoryItems = 100;
  static const _boxName = 'reading_history_box';
  
  static Box<String>? _box;
  static List<HistoryEntry>? _cache;
  
  static Future<void> _ensureInitialized() async {
    _box ??= await Hive.openBox<String>(_boxName);
  }
  
  /// Get reading history
  static Future<List<HistoryEntry>> getHistory() async {
    if (_cache != null) return _cache!;
    
    try {
      await _ensureInitialized();
      final jsonStr = _box?.get(_historyKey);
      
      if (jsonStr == null || jsonStr.isEmpty) {
        _cache = [];
        return [];
      }
      
      final decoded = json.decode(jsonStr);
      if (decoded is! List) {
        _cache = [];
        return [];
      }
      
      _cache = decoded
          .whereType<Map>()
          .map((j) => HistoryEntry.fromJson(Map<String, dynamic>.from(j)))
          .toList();
      return _cache!;
    } catch (_) {
      _cache = [];
      return [];
    }
  }
  
  /// Add entry to history
  static Future<void> addEntry(HistoryEntry entry) async {
    try {
      final history = await getHistory();
      
      // Remove duplicate if exists
      history.removeWhere((h) => 
        h.bookId == entry.bookId && 
        h.chapter == entry.chapter &&
        h.bibleId == entry.bibleId
      );
      
      // Add to beginning
      history.insert(0, entry);
      
      // Limit size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }
      
      _cache = history;
      
      await _ensureInitialized();
      await _box?.put(_historyKey, json.encode(history.map((h) => h.toJson()).toList()));
    } catch (e) {
      print('ReadingHistoryService: Error adding entry: $e');
    }
  }
  
  /// Clear history
  static Future<void> clearHistory() async {
    _cache = [];
    await _ensureInitialized();
    await _box?.delete(_historyKey);
  }
  
  /// Get recent history (last 7 days)
  static Future<List<HistoryEntry>> getRecentHistory({int days = 7}) async {
    final history = await getHistory();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return history.where((h) => h.readAt.isAfter(cutoff)).toList();
  }
  
  /// Get reading stats
  static Future<Map<String, dynamic>> getStats() async {
    final history = await getHistory();
    
    final uniqueBooks = <String>{};
    final uniqueChapters = <String>{};
    final bibleUsage = <String, int>{};
    
    for (final entry in history) {
      uniqueBooks.add(entry.bookId);
      uniqueChapters.add('${entry.bookId}:${entry.chapter}');
      bibleUsage[entry.bibleId] = (bibleUsage[entry.bibleId] ?? 0) + 1;
    }
    
    return {
      'totalReadings': history.length,
      'uniqueBooks': uniqueBooks.length,
      'uniqueChapters': uniqueChapters.length,
      'favoriteBible': bibleUsage.entries.fold<MapEntry<String, int>?>(
        null, 
        (prev, curr) => prev == null || curr.value > prev.value ? curr : prev
      )?.key ?? 'kjv',
    };
  }
}
