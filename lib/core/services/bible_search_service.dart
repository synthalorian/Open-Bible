import 'direct_bible_loader.dart';

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
  /// Load a Bible — delegates to DirectBibleLoader's shared LRU cache
  static Future<Map<String, dynamic>?> _loadBible(String bibleId) =>
      DirectBibleLoader.loadBible(bibleId);
  
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
      final bookName = book['name']?.toString() ?? _capitalize(bookId);
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
                final bookName = book['name']?.toString() ?? _capitalize(jsonBookId);
                
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
  
  /// Parse a Bible reference (e.g., "John 3:16", "1 Samuel 3:16", "Song of Solomon 2")
  static Map<String, dynamic>? _parseReference(String query) {
    // Match: optional number prefix, multi-word book name, chapter, optional verse
    final patterns = [
      RegExp(r'^(.+?)\s+(\d+):(\d+)$', caseSensitive: false), // John 3:16, 1 Samuel 3:16
      RegExp(r'^(.+?)\s+(\d+)$', caseSensitive: false),       // Genesis 1
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(query.trim());
      if (match != null) {
        final book = match.group(1)!.trim();
        // Validate the book name isn't purely numeric
        if (int.tryParse(book) != null) continue;
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
  
  /// Highlight search terms in text by wrapping matches in **bold** markers
  static String _highlightText(String text, List<String> terms) {
    String result = text;
    for (final term in terms) {
      if (term.isEmpty) continue;
      result = result.replaceAllMapped(
        RegExp(RegExp.escape(term), caseSensitive: false),
        (match) => '**${match.group(0)}**',
      );
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
    DirectBibleLoader.clearCache();
  }
}
