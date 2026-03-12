import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../config/bible_translations.dart';

/// The MOST STACKED offline Bible loader on Earth
class DirectBibleLoader {
  static final Map<String, Map<String, dynamic>> _cache = {};
  static final List<String> _cacheOrder = []; // LRU tracking
  static const int _maxCacheSize = 3;

  /// Clear all cached Bible data from memory
  static void clearCache() {
    _cache.clear();
    _cacheOrder.clear();
  }

  /// Load a Bible file by translation ID (public for search service)
  static Future<Map<String, dynamic>?> loadBible(String bibleId) => _loadBible(bibleId);

  static Future<Map<String, dynamic>?> _loadBible(String bibleId) async {
    final normalizedId = bibleId.toLowerCase();

    if (_cache.containsKey(normalizedId)) {
      // Move to end of LRU list (most recently used)
      _cacheOrder.remove(normalizedId);
      _cacheOrder.add(normalizedId);
      return _cache[normalizedId];
    }
    
    // Get file name from our unified config
    final fileName = BibleTranslations.getFileName(normalizedId);
    if (fileName == null) {
      debugPrint('DirectBibleLoader: Unknown Bible ID: $bibleId');
      return null;
    }
    
    try {
      debugPrint('DirectBibleLoader: Loading $fileName for ID: $bibleId');
      final jsonString = await rootBundle.loadString('assets/bible_data/$fileName');
      debugPrint('DirectBibleLoader: Loaded ${jsonString.length} chars');
      final data = json.decode(jsonString);
      debugPrint('DirectBibleLoader: Decoded JSON with ${(data['books'] as List?)?.length ?? 0} books');
      // Evict LRU entry if at capacity
      if (_cache.length >= _maxCacheSize && _cacheOrder.isNotEmpty) {
        final evictId = _cacheOrder.removeAt(0);
        _cache.remove(evictId);
        debugPrint('DirectBibleLoader: Evicted $evictId from cache');
      }
      _cache[normalizedId] = data;
      _cacheOrder.add(normalizedId);
      return data;
    } catch (e, stackTrace) {
      debugPrint('DirectBibleLoader ERROR loading $bibleId: $e');
      debugPrint('Stack: $stackTrace');
      return null;
    }
  }
  
  /// Get chapter content from a specific Bible translation
  static Future<String?> getChapter(String bibleId, String bookId, int chapter) async {
    debugPrint('DirectBibleLoader.getChapter: bibleId=$bibleId, bookId=$bookId, chapter=$chapter');
    
    final bible = await _loadBible(bibleId);
    if (bible == null) {
      debugPrint('DirectBibleLoader: Failed to load Bible: $bibleId');
      return null;
    }
    
    final books = bible['books'] as List?;
    if (books == null) {
      debugPrint('DirectBibleLoader: No books found in Bible');
      return null;
    }
    
    debugPrint('DirectBibleLoader: Found ${books.length} books');
    
    // Normalize book ID for flexible matching
    String normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final normalizedBookId = normalize(bookId);
    
    for (final book in books) {
      final bookIdInJsonRaw = book['id'].toString();
      final bookNameInJsonRaw = (book['name'] ?? '').toString();
      final bookIdInJson = normalize(bookIdInJsonRaw);
      final bookNameInJson = normalize(bookNameInJsonRaw);

      // Match by id OR human name (handles ids like JHN vs route id john)
      final isMatch =
          bookIdInJson == normalizedBookId ||
          bookNameInJson == normalizedBookId ||
          normalizedBookId.startsWith(bookIdInJson) ||
          bookIdInJson.startsWith(normalizedBookId) ||
          normalizedBookId.startsWith(bookNameInJson) ||
          bookNameInJson.startsWith(normalizedBookId) ||
          (normalizedBookId.length >= 3 && bookIdInJson == normalizedBookId.substring(0, 3));
      
      if (isMatch) {
        debugPrint('DirectBibleLoader: Found book "$bookIdInJsonRaw" ($bookNameInJsonRaw) for request "$bookId"');
        final chapters = book['chapters'] as List?;
        if (chapters == null) continue;
        
        for (final ch in chapters) {
          if (ch['chapter'] == chapter) {
            final verses = ch['verses'] as List?;
            if (verses == null) continue;
            debugPrint('DirectBibleLoader: Found chapter $chapter with ${verses.length} verses');
            return _formatVerses(verses);
          }
        }
        debugPrint('DirectBibleLoader: Chapter $chapter not found in book');
        return null;
      }
    }
    debugPrint('DirectBibleLoader: Book "$bookId" not found (tried matching: $normalizedBookId)');
    return null;
  }
  
  /// Format verses into readable text
  static String _formatVerses(List verses) {
    final buffer = StringBuffer();
    for (final verse in verses) {
      final num = verse['verse'];
      final text = verse['text']?.toString() ?? '';
      if (text.isNotEmpty) {
        buffer.writeln('$num $text\n');
      }
    }
    return buffer.toString().trim();
  }
  
  /// Get list of available Bibles (for UI)
  static List<Map<String, String>> get availableBibles => 
    BibleTranslations.all.map((t) => {
      'id': t.id,
      'name': t.fullName,
    }).toList();
  
  /// Get total Bible count
  static int get bibleCount => BibleTranslations.count;
  
  /// Get total verses (approximate)
  static String get totalVerses => '485,000+';
}
