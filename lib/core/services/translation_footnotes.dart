import 'dart:convert';
import 'package:flutter/services.dart';

/// Translation-specific footnote loader
class TranslationFootnotes {
  static final Map<String, Map<String, List<VerseFootnote>>> _cache = {};
  
  /// Load footnotes for a specific translation
  static Future<Map<String, List<VerseFootnote>>> loadFootnotes(String translationId) async {
    if (_cache.containsKey(translationId)) {
      return _cache[translationId]!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/footnotes/${translationId}_footnotes.json'
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final footnotes = <String, List<VerseFootnote>>{};
      data.forEach((key, value) {
        footnotes[key] = (value as List)
            .map((f) => VerseFootnote.fromJson(f))
            .toList();
      });
      
      _cache[translationId] = footnotes;
      return footnotes;
    } catch (e) {
      // Return empty map if no footnotes file exists
      return {};
    }
  }
  
  /// Get footnotes for a specific verse in a translation
  static Future<List<VerseFootnote>> getFootnotes(
    String translationId,
    String bookId,
    int chapter,
    int verse,
  ) async {
    final footnotes = await loadFootnotes(translationId);
    final key = '${bookId.toUpperCase()} $chapter:$verse';
    return footnotes[key] ?? [];
  }
  
  /// Clear cache
  static void clearCache() {
    _cache.clear();
  }
}

/// Verse footnote model
class VerseFootnote {
  final String id;
  final String text;
  final String type;
  final String? reference;
  
  VerseFootnote({
    required this.id,
    required this.text,
    required this.type,
    this.reference,
  });
  
  factory VerseFootnote.fromJson(Map<String, dynamic> json) => VerseFootnote(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    type: json['type'] ?? 'general',
    reference: json['reference'],
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'type': type,
    'reference': reference,
  };
}

/// Footnote types
class FootnoteTypes {
  static const String linguistic = 'linguistic';
  static const String translation = 'translation';
  static const String theological = 'theological';
  static const String historical = 'historical';
  static const String cultural = 'cultural';
  static const String interpretation = 'interpretation';
  static const String crossReference = 'crossReference';
  static const String messianic = 'messianic';
  static const String textual = 'textual';
  static const String archaeological = 'archaeological';
  static const String geographical = 'geographical';
  static const String literary = 'literary';
}
