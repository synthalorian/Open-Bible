/// Models for parsing local Bible JSON files (assets/bible_data/*.json).
/// These are distinct from the API models in bible_models.dart and the
/// catalog model in bible_book.dart.

class ParsedBibleBook {
  final String id;
  final String name;
  final List<ParsedBibleChapter> chapters;

  ParsedBibleBook({
    required this.id,
    required this.name,
    required this.chapters,
  });

  factory ParsedBibleBook.fromJson(Map<String, dynamic> json) => ParsedBibleBook(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    chapters: (json['chapters'] as List? ?? [])
        .map((c) => ParsedBibleChapter.fromJson(c))
        .toList(),
  );
}

class ParsedBibleChapter {
  final int chapter;
  final List<ParsedBibleVerse> verses;

  ParsedBibleChapter({required this.chapter, required this.verses});

  factory ParsedBibleChapter.fromJson(Map<String, dynamic> json) => ParsedBibleChapter(
    chapter: json['chapter'] ?? 0,
    verses: (json['verses'] as List? ?? [])
        .map((v) => ParsedBibleVerse.fromJson(v))
        .toList(),
  );
}

class ParsedBibleVerse {
  final int verse;
  final String text;

  ParsedBibleVerse({required this.verse, required this.text});

  factory ParsedBibleVerse.fromJson(Map<String, dynamic> json) => ParsedBibleVerse(
    verse: json['verse'] ?? 0,
    text: json['text'] ?? '',
  );
}
