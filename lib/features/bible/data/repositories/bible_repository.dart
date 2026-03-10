import 'dart:convert';
import 'package:flutter/services.dart';

/// Bible book model
class BibleBook {
  final String id;
  final String name;
  final String abbreviation;
  final int chapters;
  final Testament testament;
  
  const BibleBook({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.chapters,
    required this.testament,
  });
  
  factory BibleBook.fromJson(Map<String, dynamic> json) => BibleBook(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    abbreviation: json['abbreviation'] ?? '',
    chapters: json['chapters'] ?? 0,
    testament: _parseTestament(json['testament']),
  );
  
  static Testament _parseTestament(String? value) {
    switch (value?.toLowerCase()) {
      case 'old':
        return Testament.old;
      case 'new':
      case 'new_testament':
        return Testament.newTestament;
      default:
        return Testament.old;
    }
  }
}

enum Testament { old, newTestament }

/// Chapter data model
class ChapterData {
  final String bookId;
  final int chapter;
  final String content;
  
  const ChapterData({
    required this.bookId,
    required this.chapter,
    required this.content,
  });
}

/// Bible repository for loading Bible data
class BibleRepository {
  static final BibleRepository _instance = BibleRepository._internal();
  factory BibleRepository() => _instance;
  BibleRepository._internal();
  
  // Cache for books
  final Map<String, List<BibleBook>> _booksCache = {};
  
  /// Get books for a translation
  Future<List<BibleBook>> getBooks([String translationId = 'kjv']) async {
    if (_booksCache.containsKey(translationId)) {
      return _booksCache[translationId]!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/bible_data/$translationId/books.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final books = jsonList.map((json) => BibleBook.fromJson(json)).toList();
      _booksCache[translationId] = books;
      return books;
    } catch (e) {
      // Fallback to built-in book list
      return _getDefaultBooks();
    }
  }
  
  /// Get a specific chapter
  Future<ChapterData?> getChapter(String translationId, String bookId, int chapter) async {
    try {
      final String content = await rootBundle.loadString(
        'assets/bible_data/$translationId/$bookId/$chapter.json',
      );
      final json = jsonDecode(content);
      return ChapterData(
        bookId: bookId,
        chapter: chapter,
        content: json['content'] ?? json['text'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get default book list
  List<BibleBook> _getDefaultBooks() {
    return const [
      // Old Testament
      BibleBook(id: 'GEN', name: 'Genesis', abbreviation: 'Gen', chapters: 50, testament: Testament.old),
      BibleBook(id: 'EXO', name: 'Exodus', abbreviation: 'Exo', chapters: 40, testament: Testament.old),
      BibleBook(id: 'LEV', name: 'Leviticus', abbreviation: 'Lev', chapters: 27, testament: Testament.old),
      BibleBook(id: 'NUM', name: 'Numbers', abbreviation: 'Num', chapters: 36, testament: Testament.old),
      BibleBook(id: 'DEU', name: 'Deuteronomy', abbreviation: 'Deu', chapters: 34, testament: Testament.old),
      BibleBook(id: 'JOS', name: 'Joshua', abbreviation: 'Jos', chapters: 24, testament: Testament.old),
      BibleBook(id: 'JDG', name: 'Judges', abbreviation: 'Jdg', chapters: 21, testament: Testament.old),
      BibleBook(id: 'RUT', name: 'Ruth', abbreviation: 'Rut', chapters: 4, testament: Testament.old),
      BibleBook(id: '1SA', name: '1 Samuel', abbreviation: '1Sa', chapters: 31, testament: Testament.old),
      BibleBook(id: '2SA', name: '2 Samuel', abbreviation: '2Sa', chapters: 24, testament: Testament.old),
      BibleBook(id: '1KI', name: '1 Kings', abbreviation: '1Ki', chapters: 22, testament: Testament.old),
      BibleBook(id: '2KI', name: '2 Kings', abbreviation: '2Ki', chapters: 25, testament: Testament.old),
      BibleBook(id: '1CH', name: '1 Chronicles', abbreviation: '1Ch', chapters: 29, testament: Testament.old),
      BibleBook(id: '2CH', name: '2 Chronicles', abbreviation: '2Ch', chapters: 36, testament: Testament.old),
      BibleBook(id: 'EZR', name: 'Ezra', abbreviation: 'Ezr', chapters: 10, testament: Testament.old),
      BibleBook(id: 'NEH', name: 'Nehemiah', abbreviation: 'Neh', chapters: 13, testament: Testament.old),
      BibleBook(id: 'EST', name: 'Esther', abbreviation: 'Est', chapters: 10, testament: Testament.old),
      BibleBook(id: 'JOB', name: 'Job', abbreviation: 'Job', chapters: 42, testament: Testament.old),
      BibleBook(id: 'PSA', name: 'Psalms', abbreviation: 'Psa', chapters: 150, testament: Testament.old),
      BibleBook(id: 'PRO', name: 'Proverbs', abbreviation: 'Pro', chapters: 31, testament: Testament.old),
      BibleBook(id: 'ECC', name: 'Ecclesiastes', abbreviation: 'Ecc', chapters: 12, testament: Testament.old),
      BibleBook(id: 'SNG', name: 'Song of Solomon', abbreviation: 'Son', chapters: 8, testament: Testament.old),
      BibleBook(id: 'ISA', name: 'Isaiah', abbreviation: 'Isa', chapters: 66, testament: Testament.old),
      BibleBook(id: 'JER', name: 'Jeremiah', abbreviation: 'Jer', chapters: 52, testament: Testament.old),
      BibleBook(id: 'LAM', name: 'Lamentations', abbreviation: 'Lam', chapters: 5, testament: Testament.old),
      BibleBook(id: 'EZK', name: 'Ezekiel', abbreviation: 'Eze', chapters: 48, testament: Testament.old),
      BibleBook(id: 'DAN', name: 'Daniel', abbreviation: 'Dan', chapters: 12, testament: Testament.old),
      BibleBook(id: 'HOS', name: 'Hosea', abbreviation: 'Hos', chapters: 14, testament: Testament.old),
      BibleBook(id: 'JOL', name: 'Joel', abbreviation: 'Joe', chapters: 3, testament: Testament.old),
      BibleBook(id: 'AMO', name: 'Amos', abbreviation: 'Amo', chapters: 9, testament: Testament.old),
      BibleBook(id: 'OBA', name: 'Obadiah', abbreviation: 'Oba', chapters: 1, testament: Testament.old),
      BibleBook(id: 'JON', name: 'Jonah', abbreviation: 'Jon', chapters: 4, testament: Testament.old),
      BibleBook(id: 'MIC', name: 'Micah', abbreviation: 'Mic', chapters: 7, testament: Testament.old),
      BibleBook(id: 'NAM', name: 'Nahum', abbreviation: 'Nah', chapters: 3, testament: Testament.old),
      BibleBook(id: 'HAB', name: 'Habakkuk', abbreviation: 'Hab', chapters: 3, testament: Testament.old),
      BibleBook(id: 'ZEP', name: 'Zephaniah', abbreviation: 'Zep', chapters: 3, testament: Testament.old),
      BibleBook(id: 'HAG', name: 'Haggai', abbreviation: 'Hag', chapters: 2, testament: Testament.old),
      BibleBook(id: 'ZEC', name: 'Zechariah', abbreviation: 'Zec', chapters: 14, testament: Testament.old),
      BibleBook(id: 'MAL', name: 'Malachi', abbreviation: 'Mal', chapters: 4, testament: Testament.old),
      // New Testament
      BibleBook(id: 'MAT', name: 'Matthew', abbreviation: 'Mat', chapters: 28, testament: Testament.newTestament),
      BibleBook(id: 'MRK', name: 'Mark', abbreviation: 'Mar', chapters: 16, testament: Testament.newTestament),
      BibleBook(id: 'LUK', name: 'Luke', abbreviation: 'Luk', chapters: 24, testament: Testament.newTestament),
      BibleBook(id: 'JHN', name: 'John', abbreviation: 'Joh', chapters: 21, testament: Testament.newTestament),
      BibleBook(id: 'ACT', name: 'Acts', abbreviation: 'Act', chapters: 28, testament: Testament.newTestament),
      BibleBook(id: 'ROM', name: 'Romans', abbreviation: 'Rom', chapters: 16, testament: Testament.newTestament),
      BibleBook(id: '1CO', name: '1 Corinthians', abbreviation: '1Co', chapters: 16, testament: Testament.newTestament),
      BibleBook(id: '2CO', name: '2 Corinthians', abbreviation: '2Co', chapters: 13, testament: Testament.newTestament),
      BibleBook(id: 'GAL', name: 'Galatians', abbreviation: 'Gal', chapters: 6, testament: Testament.newTestament),
      BibleBook(id: 'EPH', name: 'Ephesians', abbreviation: 'Eph', chapters: 6, testament: Testament.newTestament),
      BibleBook(id: 'PHP', name: 'Philippians', abbreviation: 'Phi', chapters: 4, testament: Testament.newTestament),
      BibleBook(id: 'COL', name: 'Colossians', abbreviation: 'Col', chapters: 4, testament: Testament.newTestament),
      BibleBook(id: '1TH', name: '1 Thessalonians', abbreviation: '1Th', chapters: 5, testament: Testament.newTestament),
      BibleBook(id: '2TH', name: '2 Thessalonians', abbreviation: '2Th', chapters: 3, testament: Testament.newTestament),
      BibleBook(id: '1TI', name: '1 Timothy', abbreviation: '1Ti', chapters: 6, testament: Testament.newTestament),
      BibleBook(id: '2TI', name: '2 Timothy', abbreviation: '2Ti', chapters: 4, testament: Testament.newTestament),
      BibleBook(id: 'TIT', name: 'Titus', abbreviation: 'Tit', chapters: 3, testament: Testament.newTestament),
      BibleBook(id: 'PHM', name: 'Philemon', abbreviation: 'Phm', chapters: 1, testament: Testament.newTestament),
      BibleBook(id: 'HEB', name: 'Hebrews', abbreviation: 'Heb', chapters: 13, testament: Testament.newTestament),
      BibleBook(id: 'JAS', name: 'James', abbreviation: 'Jam', chapters: 5, testament: Testament.newTestament),
      BibleBook(id: '1PE', name: '1 Peter', abbreviation: '1Pe', chapters: 5, testament: Testament.newTestament),
      BibleBook(id: '2PE', name: '2 Peter', abbreviation: '2Pe', chapters: 3, testament: Testament.newTestament),
      BibleBook(id: '1JN', name: '1 John', abbreviation: '1Jo', chapters: 5, testament: Testament.newTestament),
      BibleBook(id: '2JN', name: '2 John', abbreviation: '2Jo', chapters: 1, testament: Testament.newTestament),
      BibleBook(id: '3JN', name: '3 John', abbreviation: '3Jo', chapters: 1, testament: Testament.newTestament),
      BibleBook(id: 'JUD', name: 'Jude', abbreviation: 'Jud', chapters: 1, testament: Testament.newTestament),
      BibleBook(id: 'REV', name: 'Revelation', abbreviation: 'Rev', chapters: 22, testament: Testament.newTestament),
    ];
  }
}
