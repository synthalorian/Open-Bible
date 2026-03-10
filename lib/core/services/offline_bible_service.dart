import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing offline Bible data - loads directly from assets
class OfflineBibleService {
  static const String _metadataKey = 'bible_metadata_';
  
  bool _isInitialized = false;
  
  // Cache for loaded Bible data
  final Map<String, Map<String, dynamic>> _bibleCache = {};
  
  bool get isInitialized => _isInitialized;
  
  /// Initialize - preload Bible data into memory
  Future<void> init() async {
    // No persistent storage needed - we'll load from assets on demand
    _isInitialized = true;
  }
  
  /// Load Bible data from bundled JSON files
  Future<void> loadBundledBibleData() async {
    final bundledBibles = [
      {'file': 'kjv_bible.json', 'id': 'kjv'},
      {'file': 'web_bible.json', 'id': 'web'},
      {'file': 'asv_bible.json', 'id': 'asv'},
      {'file': 'akjv_bible.json', 'id': 'akjv'},
      {'file': 'ylt_bible.json', 'id': 'ylt'},
    ];
    
    for (final bibleInfo in bundledBibles) {
      try {
        final String jsonString = await rootBundle.loadString('assets/bible_data/${bibleInfo['file']}');
        final Map<String, dynamic> bibleData = json.decode(jsonString);
        _bibleCache[bibleInfo['id']!] = bibleData;
        print('Offline Bible data loaded: ${bibleInfo['id']}');
      } catch (e) {
        print('Error loading bundled Bible data for ${bibleInfo['id']}: $e');
      }
    }
  }
  
  /// Check if offline Bible data is available
  bool hasOfflineData(String bibleId) {
    return _bibleCache.containsKey(bibleId);
  }
  
  /// Get chapter content from local data
  String? getChapterContent(String bibleId, String bookId, int chapter) {
    final bibleData = _bibleCache[bibleId];
    if (bibleData == null) return null;
    
    final books = bibleData['books'] as List?;
    if (books == null) return null;
    
    for (final book in books) {
      if (book['id'] == bookId) {
        final chapters = book['chapters'] as List?;
        if (chapters == null) return null;
        
        for (final ch in chapters) {
          if (ch['chapter'] == chapter) {
            final verses = ch['verses'] as List?;
            if (verses == null) return null;
            return _formatVerses(verses);
          }
        }
      }
    }
    return null;
  }
  
  String _formatVerses(List verses) {
    final buffer = StringBuffer();
    for (final verse in verses) {
      final verseNum = verse['verse'];
      final text = verse['text'];
      buffer.writeln('$verseNum. $text');
    }
    return buffer.toString();
  }
  
  /// Get list of available offline translations
  List<Map<String, dynamic>> getAvailableTranslations() {
    final translations = <Map<String, dynamic>>[];
    
    for (final entry in _bibleCache.entries) {
      final bibleData = entry.value;
      translations.add({
        'id': entry.key,
        'name': bibleData['name'] ?? entry.key.toUpperCase(),
        'abbreviation': bibleData['abbreviation'] ?? entry.key.toUpperCase(),
        'bookCount': (bibleData['books'] as List?)?.length ?? 0,
      });
    }
    
    return translations;
  }
  
  /// Clear all offline Bible data (just clears memory cache)
  Future<void> clearAllData() async {
    _bibleCache.clear();
  }
  
  /// Get download progress (always 100% since data is bundled)
  double getDownloadProgress(String bibleId, int totalChapters) {
    return _bibleCache.containsKey(bibleId) ? 1.0 : 0.0;
  }
}
