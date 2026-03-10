import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/bible_translations.dart';

/// The MOST STACKED offline Bible loader on Earth
class DirectBibleLoader {
  static final Map<String, Map<String, dynamic>> _cache = {};
  
  /// Load a Bible file by translation ID
  static Future<Map<String, dynamic>?> _loadBible(String bibleId) async {
    final normalizedId = bibleId.toLowerCase();
    
    if (_cache.containsKey(normalizedId)) return _cache[normalizedId];
    
    // Get file name from our unified config
    final fileName = BibleTranslations.getFileName(normalizedId);
    if (fileName == null) {
      print('DirectBibleLoader: Unknown Bible ID: $bibleId');
      return null;
    }
    
    try {
      print('DirectBibleLoader: Loading $fileName for ID: $bibleId');
      final jsonString = await rootBundle.loadString('assets/bible_data/$fileName');
      print('DirectBibleLoader: Loaded ${jsonString.length} chars');
      final data = json.decode(jsonString);
      print('DirectBibleLoader: Decoded JSON with ${(data['books'] as List?)?.length ?? 0} books');
      _cache[normalizedId] = data;
      return data;
    } catch (e, stackTrace) {
      print('DirectBibleLoader ERROR loading $bibleId: $e');
      print('Stack: $stackTrace');
      return null;
    }
  }
  
  /// Get chapter content from a specific Bible translation
  static Future<String?> getChapter(String bibleId, String bookId, int chapter) async {
    print('DirectBibleLoader.getChapter: bibleId=$bibleId, bookId=$bookId, chapter=$chapter');
    
    final bible = await _loadBible(bibleId);
    if (bible == null) {
      print('DirectBibleLoader: Failed to load Bible: $bibleId');
      return null;
    }
    
    final books = bible['books'] as List?;
    if (books == null) {
      print('DirectBibleLoader: No books found in Bible');
      return null;
    }
    
    print('DirectBibleLoader: Found ${books.length} books');
    
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
        print('DirectBibleLoader: Found book "$bookIdInJsonRaw" ($bookNameInJsonRaw) for request "$bookId"');
        final chapters = book['chapters'] as List?;
        if (chapters == null) continue;
        
        for (final ch in chapters) {
          if (ch['chapter'] == chapter) {
            final verses = ch['verses'] as List?;
            if (verses == null) continue;
            print('DirectBibleLoader: Found chapter $chapter with ${verses.length} verses');
            return _formatVerses(verses);
          }
        }
        print('DirectBibleLoader: Chapter $chapter not found in book');
        return null;
      }
    }
    print('DirectBibleLoader: Book "$bookId" not found (tried matching: $normalizedBookId)');
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
