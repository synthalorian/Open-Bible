/// Core domain models for Bible data
library;

/// Represents a Bible translation/version
class BibleTranslation {
  final String id;
  final String name;
  final String nameLocal;
  final String abbreviation;
  final String abbreviationLocal;
  final String description;
  final String language;
  final String languageId;
  final bool isPublicDomain;
  final bool isFree;
  final bool isDownloaded;
  final int? downloadSize;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.nameLocal,
    required this.abbreviation,
    required this.abbreviationLocal,
    required this.description,
    required this.language,
    required this.languageId,
    this.isPublicDomain = false,
    this.isFree = true,
    this.isDownloaded = false,
    this.downloadSize,
  });

  factory BibleTranslation.fromJson(Map<String, dynamic> json) {
    // Handle both API format and simple format
    final language = json['language'];
    final languageName = language is Map 
        ? (language['name'] ?? 'English')
        : (language ?? 'English');
    final languageId = language is Map
        ? (language['id'] ?? 'eng')
        : (json['languageId'] ?? 'eng');
    
    return BibleTranslation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameLocal: json['nameLocal'] ?? json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      abbreviationLocal: json['abbreviationLocal'] ?? json['abbreviation'] ?? '',
      description: json['description'] ?? json['name'] ?? '',
      language: languageName,
      languageId: languageId,
      isPublicDomain: json['publicDomain'] ?? json['isPublicDomain'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameLocal': nameLocal,
    'abbreviation': abbreviation,
    'abbreviationLocal': abbreviationLocal,
    'description': description,
    'language': language,
    'languageId': languageId,
    'isPublicDomain': isPublicDomain,
    'isFree': isFree,
    'isDownloaded': isDownloaded,
    'downloadSize': downloadSize,
  };
}

/// Represents a book of the Bible
class BibleBook {
  final String id;
  final String name;
  final String nameLong;
  final String abbreviation;
  final int testament; // 1 = OT, 2 = NT
  final int position;
  final int chapterCount;

  const BibleBook({
    required this.id,
    required this.name,
    required this.nameLong,
    required this.abbreviation,
    required this.testament,
    required this.position,
    required this.chapterCount,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameLong: json['nameLong'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      testament: json['testament'] ?? 1,
      position: json['number'] ?? 1,
      chapterCount: json['chaptersCount'] ?? 0,
    );
  }

  bool get isOldTestament => testament == 1;
  bool get isNewTestament => testament == 2;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameLong': nameLong,
    'abbreviation': abbreviation,
    'testament': testament,
    'position': position,
    'chapterCount': chapterCount,
  };
}

/// Represents a chapter reference
class ChapterRef {
  final String id;
  final String bookId;
  final String bookName;
  final int number;
  final int verseCount;

  const ChapterRef({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.number,
    required this.verseCount,
  });

  String get reference => '$bookName $number';

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'bookName': bookName,
    'number': number,
    'verseCount': verseCount,
  };

  factory ChapterRef.fromJson(Map<String, dynamic> json) {
    return ChapterRef(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookName: json['bookName'] ?? '',
      number: json['number'] ?? 1,
      verseCount: json['verseCount'] ?? 0,
    );
  }
}

/// Represents a single verse
class Verse {
  final String id;
  final String bookId;
  final String chapterId;
  final int chapter;
  final int verse;
  final String text;
  final String? translationId;

  const Verse({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapter,
    required this.verse,
    required this.text,
    this.translationId,
  });

  /// Full reference (e.g., "John 3:16")
  String get reference {
    // Extract book name from bookId (e.g., "JHN" -> need mapping)
    return '${bookId.toUpperCase()} $chapter:$verse';
  }

  /// Short reference (e.g., "3:16")
  String get shortReference => '$chapter:$verse';

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      chapterId: json['chapterId'] ?? '',
      chapter: json['chapter'] ?? 1,
      verse: json['verse'] ?? 1,
      text: json['text'] ?? '',
      translationId: json['translationId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'chapterId': chapterId,
    'chapter': chapter,
    'verse': verse,
    'text': text,
    'translationId': translationId,
  };
}

/// Full verse with additional metadata for display
class VerseWithMetadata extends Verse {
  final bool isBookmarked;
  final bool isHighlighted;
  final int? highlightColor;
  final bool hasNote;
  final bool hasCrossReferences;

  const VerseWithMetadata({
    required super.id,
    required super.bookId,
    required super.chapterId,
    required super.chapter,
    required super.verse,
    required super.text,
    super.translationId,
    this.isBookmarked = false,
    this.isHighlighted = false,
    this.highlightColor,
    this.hasNote = false,
    this.hasCrossReferences = false,
  });

  factory VerseWithMetadata.fromVerse(
    Verse verse, {
    bool isBookmarked = false,
    bool isHighlighted = false,
    int? highlightColor,
    bool hasNote = false,
    bool hasCrossReferences = false,
  }) {
    return VerseWithMetadata(
      id: verse.id,
      bookId: verse.bookId,
      chapterId: verse.chapterId,
      chapter: verse.chapter,
      verse: verse.verse,
      text: verse.text,
      translationId: verse.translationId,
      isBookmarked: isBookmarked,
      isHighlighted: isHighlighted,
      highlightColor: highlightColor,
      hasNote: hasNote,
      hasCrossReferences: hasCrossReferences,
    );
  }
}

/// Represents a verse reference (for cross-references, citations)
class VerseReference {
  final String bookId;
  final String bookName;
  final int chapter;
  final int? verseStart;
  final int? verseEnd;

  const VerseReference({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    this.verseStart,
    this.verseEnd,
  });

  /// Single verse reference (e.g., "John 3:16")
  bool get isSingleVerse => verseStart != null && verseEnd == null;

  /// Verse range (e.g., "John 3:16-18")
  bool get isRange => verseStart != null && verseEnd != null;

  /// Chapter reference (e.g., "John 3")
  bool get isChapterOnly => verseStart == null;

  String get display {
    if (isChapterOnly) return '$bookName $chapter';
    if (isSingleVerse) return '$bookName $chapter:$verseStart';
    return '$bookName $chapter:$verseStart-$verseEnd';
  }

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookName': bookName,
    'chapter': chapter,
    'verseStart': verseStart,
    'verseEnd': verseEnd,
  };

  factory VerseReference.fromJson(Map<String, dynamic> json) {
    return VerseReference(
      bookId: json['bookId'] ?? '',
      bookName: json['bookName'] ?? '',
      chapter: json['chapter'] ?? 1,
      verseStart: json['verseStart'],
      verseEnd: json['verseEnd'],
    );
  }
}
