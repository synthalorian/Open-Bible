import 'package:flutter_test/flutter_test.dart';
import 'package:open_bible/core/services/verse_storage_service.dart';

void main() {
  group('SavedVerse', () {
    final now = DateTime(2026, 4, 12, 10, 30);

    SavedVerse makeVerse({
      String id = 'GEN.1.1',
      String bookId = 'GEN',
      String bookName = 'Genesis',
      int chapter = 1,
      int verse = 1,
      String text = 'In the beginning God created the heaven and the earth.',
      String? note,
      String? highlightColor,
      int? highlightStart,
      int? highlightEnd,
      String? highlightText,
      String bibleId = 'kjv',
    }) {
      return SavedVerse(
        id: id,
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        note: note,
        highlightColor: highlightColor,
        highlightStart: highlightStart,
        highlightEnd: highlightEnd,
        highlightText: highlightText,
        savedAt: now,
        bibleId: bibleId,
      );
    }

    test('reference returns "BookName chapter:verse"', () {
      final v = makeVerse();
      expect(v.reference, 'Genesis 1:1');
    });

    test('reference with multi-word book', () {
      final v = makeVerse(bookName: '1 Corinthians', chapter: 13, verse: 4);
      expect(v.reference, '1 Corinthians 13:4');
    });

    test('toJson round-trips through fromJson', () {
      final original = makeVerse(
        note: 'Test note',
        highlightColor: 'yellow',
        highlightStart: 0,
        highlightEnd: 10,
        highlightText: 'In the beg',
      );
      final json = original.toJson();
      final restored = SavedVerse.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.bookId, original.bookId);
      expect(restored.bookName, original.bookName);
      expect(restored.chapter, original.chapter);
      expect(restored.verse, original.verse);
      expect(restored.text, original.text);
      expect(restored.note, original.note);
      expect(restored.highlightColor, original.highlightColor);
      expect(restored.highlightStart, original.highlightStart);
      expect(restored.highlightEnd, original.highlightEnd);
      expect(restored.highlightText, original.highlightText);
      expect(restored.bibleId, original.bibleId);
      expect(restored.savedAt.toIso8601String(), original.savedAt.toIso8601String());
    });

    test('fromJson handles missing/null fields gracefully', () {
      final v = SavedVerse.fromJson({});
      expect(v.id, '');
      expect(v.bookId, '');
      expect(v.bookName, '');
      expect(v.chapter, 0);
      expect(v.verse, 0);
      expect(v.text, '');
      expect(v.note, isNull);
      expect(v.highlightColor, isNull);
      expect(v.bibleId, 'kjv');
    });

    test('fromJson uses default bibleId when missing', () {
      final v = SavedVerse.fromJson({'id': 'test'});
      expect(v.bibleId, 'kjv');
    });

    test('copyWith replaces specified fields only', () {
      final original = makeVerse();
      final modified = original.copyWith(
        note: 'New note',
        highlightColor: 'blue',
      );
      expect(modified.note, 'New note');
      expect(modified.highlightColor, 'blue');
      expect(modified.id, original.id);
      expect(modified.text, original.text);
      expect(modified.chapter, original.chapter);
    });

    test('copyWith with no args returns equivalent object', () {
      final original = makeVerse(note: 'A note');
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.note, original.note);
      expect(copy.savedAt, original.savedAt);
    });

    test('toJson includes all nullable fields when set', () {
      final v = makeVerse(
        note: 'note',
        highlightColor: 'green',
        highlightStart: 5,
        highlightEnd: 20,
        highlightText: 'selected text',
      );
      final json = v.toJson();
      expect(json['note'], 'note');
      expect(json['highlightColor'], 'green');
      expect(json['highlightStart'], 5);
      expect(json['highlightEnd'], 20);
      expect(json['highlightText'], 'selected text');
    });

    test('toJson has null for unset nullable fields', () {
      final v = makeVerse();
      final json = v.toJson();
      expect(json['note'], isNull);
      expect(json['highlightColor'], isNull);
      expect(json['highlightStart'], isNull);
      expect(json['highlightEnd'], isNull);
      expect(json['highlightText'], isNull);
    });
  });

  group('HighlightColors', () {
    test('all contains exactly 6 colors', () {
      expect(HighlightColors.all.length, 6);
    });

    test('getColorValue returns correct hex for each color', () {
      expect(HighlightColors.getColorValue('yellow'), 0xFFFFEB3B);
      expect(HighlightColors.getColorValue('green'), 0xFF4CAF50);
      expect(HighlightColors.getColorValue('blue'), 0xFF2196F3);
      expect(HighlightColors.getColorValue('pink'), 0xFFE91E63);
      expect(HighlightColors.getColorValue('orange'), 0xFFFF9800);
      expect(HighlightColors.getColorValue('purple'), 0xFF9C27B0);
    });

    test('getColorValue defaults to yellow for unknown color', () {
      expect(HighlightColors.getColorValue('red'), 0xFFFFEB3B);
      expect(HighlightColors.getColorValue(''), 0xFFFFEB3B);
    });

    test('color constants match all list', () {
      expect(HighlightColors.all, [
        HighlightColors.yellow,
        HighlightColors.green,
        HighlightColors.blue,
        HighlightColors.pink,
        HighlightColors.orange,
        HighlightColors.purple,
      ]);
    });
  });
}
