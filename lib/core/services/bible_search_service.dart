import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/bible_translations.dart';

/// Search result model
class SearchResult {
  final String bibleId;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String highlightedText;
  
  const SearchResult({
    required this.bibleId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.highlightedText,
  });
  
  String get reference => '$bookName $chapter:$verse';
}

/// Bible search service - searches through all Bible content
class BibleSearchService {
  static final Map<String, Map<String, dynamic>> _bibleCache = {};
  static final Map<String, String> _bookNames = {
    'genesis': 'Genesis', 'exodus': 'Exodus', 'leviticus': 'Leviticus',
    'numbers': 'Numbers', 'deuteronomy': 'Deuteronomy', 'joshua': 'Joshua',
    'judges': 'Judges', 'ruth': 'Ruth', '1 samuel': '1 Samuel', '2 samuel': '2 Samuel',
    '1 kings': '1 Kings', '2 kings': '2 Kings', '1 chronicles': '1 Chronicles',
    '2 chronicles': '2 Chronicles', 'ezra': 'Ezra', 'nehemiah': 'Nehemiah',
    'esther': 'Esther', 'job': 'Job', 'psalms': 'Psalms', 'proverbs': 'Proverbs',
    'ecclesiastes': 'Ecclesiastes', 'song of solomon': 'Song of Solomon',
    'isaiah': 'Isaiah', 'jeremiah': 'Jeremiah', 'lamentations': 'Lamentations',
    'ezekiel': 'Ezekiel', 'daniel': 'Daniel', 'hosea': 'Hosea', 'joel': 'Joel',
    'amos': 'Amos', 'obadiah': 'Obadiah', 'jonah': 'Jonah', 'micah': 'Micah',
    'nahum': 'Nahum', 'habakkuk': 'Habakkuk', 'zephaniah': 'Zephaniah',
    'haggai': 'Haggai', 'zechariah': 'Zechariah', 'malachi': 'Malachi',
    'matthew': 'Matthew', 'mark': 'Mark', 'luke': 'Luke', 'john': 'John',
    'acts': 'Acts', 'romans': 'Romans', '1 corinthians': '1 Corinthians',
    '2 corinthians': '2 Corinthians', 'galatians': 'Galatians', 'ephesians': 'Ephesians',
    'philippians': 'Philippians', 'colossians': 'Colossians',
    '1 thessalonians': '1 Thessalonians', '2 thessalonians': '2 Thessalonians',
    '1 timothy': '1 Timothy', '2 timothy': '2 Timothy', 'titus': 'Titus',
    'philemon': 'Philemon', 'hebrews': 'Hebrews', 'james': 'James',
    '1 peter': '1 Peter', '2 peter': '2 Peter', '1 john': '1 John',
    '2 john': '2 John', '3 john': '3 John', 'jude': 'Jude', 'revelation': 'Revelation',
  };
  
  /// Load a Bible into cache
  static Future<Map<String, dynamic>?> _loadBible(String bibleId) async {
    final normalizedId = bibleId.toLowerCase();
    if (_bibleCache.containsKey(normalizedId)) {
      return _bibleCache[normalizedId];
    }
    
    final fileName = BibleTranslations.getFileName(normalizedId);
    if (fileName == null) return null;
    
    try {
      final jsonString = await rootBundle.loadString('assets/bible_data/$fileName');
      final data = json.decode(jsonString);
      _bibleCache[normalizedId] = data;
      return data;
    } catch (e) {
      print('Error loading Bible $bibleId: $e');
      return null;
    }
  }
  
  /// Search for verses containing the query
  static Future<List<SearchResult>> search(
    String query, {
    String bibleId = 'kjv',
    int maxResults = 100,
  }) async {
    if (query.trim().isEmpty) return [];
    
    final results = <SearchResult>[];
    final searchTerms = query.toLowerCase().trim().split(RegExp(r'\s+'));
    
    // Check if query is a reference (e.g., "John 3:16")
    final referenceResults = _parseReference(query);
    if (referenceResults != null) {
      // Load the verse for the reference
      final verse = await _getVerse(bibleId, referenceResults['book']!, 
          referenceResults['chapter']!, referenceResults['verse']!);
      if (verse != null) {
        results.add(verse);
      }
    }
    
    // Load Bible and search
    final bible = await _loadBible(bibleId);
    if (bible == null) return results;
    
    final books = bible['books'] as List?;
    if (books == null) return results;
    
    for (final book in books) {
      final bookId = book['id'].toString().toLowerCase();
      final bookName = _bookNames[bookId] ?? _capitalize(bookId);
      final chapters = book['chapters'] as List?;
      if (chapters == null) continue;
      
      for (final chapter in chapters) {
        final chapterNum = chapter['chapter'] as int? ?? 0;
        final verses = chapter['verses'] as List?;
        if (verses == null) continue;
        
        for (final verse in verses) {
          final verseNum = verse['verse'] as int? ?? 0;
          final text = verse['text']?.toString() ?? '';
          if (text.isEmpty) continue;
          
          final textLower = text.toLowerCase();
          
          // Check if all search terms are in the verse
          bool matches = true;
          for (final term in searchTerms) {
            if (!textLower.contains(term)) {
              matches = false;
              break;
            }
          }
          
          if (matches) {
            results.add(SearchResult(
              bibleId: bibleId,
              bookId: bookId,
              bookName: bookName,
              chapter: chapterNum,
              verse: verseNum,
              text: text,
              highlightedText: _highlightText(text, searchTerms),
            ));
            
            if (results.length >= maxResults) {
              return results;
            }
          }
        }
      }
    }
    
    return results;
  }
  
  /// Get a single verse
  static Future<SearchResult?> _getVerse(
    String bibleId, String bookId, int chapter, int verse,
  ) async {
    final bible = await _loadBible(bibleId);
    if (bible == null) return null;
    
    final books = bible['books'] as List?;
    if (books == null) return null;
    
    final bookIdLower = bookId.toLowerCase();
    
    for (final book in books) {
      final jsonBookId = book['id'].toString().toLowerCase();
      
      // Flexible matching
      if (jsonBookId == bookIdLower || 
          jsonBookId.startsWith(bookIdLower) ||
          bookIdLower.startsWith(jsonBookId)) {
        
        final chapters = book['chapters'] as List?;
        if (chapters == null) continue;
        
        for (final ch in chapters) {
          if (ch['chapter'] == chapter) {
            final verses = ch['verses'] as List?;
            if (verses == null) continue;
            
            for (final v in verses) {
              if (v['verse'] == verse) {
                final text = v['text']?.toString() ?? '';
                final bookName = _bookNames[jsonBookId] ?? _capitalize(jsonBookId);
                
                return SearchResult(
                  bibleId: bibleId,
                  bookId: jsonBookId,
                  bookName: bookName,
                  chapter: chapter,
                  verse: verse,
                  text: text,
                  highlightedText: text,
                );
              }
            }
          }
        }
      }
    }
    
    return null;
  }
  
  /// Parse a Bible reference (e.g., "John 3:16" or "Genesis 1")
  static Map<String, dynamic>? _parseReference(String query) {
    // Try to match patterns like "John 3:16", "Gen 1:1", "Psalm 23"
    final patterns = [
      RegExp(r'^(\d?\s*\w+)\s+(\d+):(\d+)$', caseSensitive: false), // John 3:16
      RegExp(r'^(\d?\s*\w+)\s+(\d+)$', caseSensitive: false),       // Genesis 1
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(query.trim());
      if (match != null) {
        final book = match.group(1)!.trim();
        final chapter = int.parse(match.group(2)!);
        final verse = match.groupCount >= 3 ? int.tryParse(match.group(3) ?? '1') ?? 1 : 1;
        
        return {
          'book': book,
          'chapter': chapter,
          'verse': verse,
        };
      }
    }
    
    return null;
  }
  
  /// Highlight search terms in text
  static String _highlightText(String text, List<String> terms) {
    String result = text;
    for (final term in terms) {
      if (term.isEmpty) continue;
      // We'll return the text as-is; highlighting will be done in the UI
    }
    return result;
  }
  
  /// Capitalize first letter
  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
  
  /// Preload Bibles into cache for faster searching
  static Future<void> preloadBibles(List<String> bibleIds) async {
    for (final id in bibleIds) {
      await _loadBible(id);
    }
  }
  
  /// Clear cache
  static void clearCache() {
    _bibleCache.clear();
  }
}
