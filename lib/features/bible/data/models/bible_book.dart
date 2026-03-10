/// Testament enum
enum Testament { old, newTestament }

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
