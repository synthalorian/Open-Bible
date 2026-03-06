import 'dart:convert';
import 'package:flutter/services.dart';

class FootnoteService {
  static final Map<String, List<FootnoteEntry>> _bookCache = {};
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    // Don't preload - load on demand
  }

  static Future<List<Footnote>> getFootnotes(String bookId, int chapter, int verse) async {
    await _ensureBookLoaded(bookId);
    
    final bookFootnotes = _bookCache[bookId];
    if (bookFootnotes == null) return [];
    
    final entry = bookFootnotes.firstWhere(
      (f) => f.chapter == chapter && f.verse == verse,
      orElse: () => FootnoteEntry(bookId: bookId, chapter: chapter, verse: verse, footnotes: []),
    );
    
    return entry.footnotes;
  }

  static Future<bool> hasFootnotes(String bookId, int chapter, int verse) async {
    final footnotes = await getFootnotes(bookId, chapter, verse);
    return footnotes.isNotEmpty;
  }

  static Future<void> _ensureBookLoaded(String bookId) async {
    if (_bookCache.containsKey(bookId)) return;
    
    try {
      // Load specific book file
      final String jsonString = await rootBundle.loadString('assets/data/footnotes/$bookId.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _bookCache[bookId] = jsonData.map((json) => FootnoteEntry.fromJson(json)).toList();
    } catch (e) {
      // Book not found or error - cache empty list
      _bookCache[bookId] = [];
    }
  }

  static void clearCache() {
    _bookCache.clear();
  }
}

class FootnoteEntry {
  final String bookId;
  final int chapter;
  final int verse;
  final List<Footnote> footnotes;

  FootnoteEntry({
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.footnotes,
  });

  factory FootnoteEntry.fromJson(Map<String, dynamic> json) {
    return FootnoteEntry(
      bookId: json['bookId'] ?? '',
      chapter: json['chapter'] ?? 0,
      verse: json['verse'] ?? 0,
      footnotes: (json['footnotes'] as List? ?? [])
          .map((f) => Footnote.fromJson(f))
          .toList(),
    );
  }
}

class Footnote {
  final String id;
  final String type;
  final String text;
  final List<String> references;

  Footnote({
    required this.id,
    required this.type,
    required this.text,
    this.references = const [],
  });

  factory Footnote.fromJson(Map<String, dynamic> json) {
    return Footnote(
      id: json['id'] ?? '',
      type: json['type'] ?? 'study_note',
      text: json['text'] ?? '',
      references: List<String>.from(json['references'] ?? []),
    );
  }

  bool get isCrossReference => type == 'cross_reference';
  bool get isStudyNote => type == 'study_note';
}
