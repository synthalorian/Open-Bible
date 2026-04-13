import 'package:flutter_test/flutter_test.dart';
import 'package:open_bible/core/services/reading_history_service.dart';

void main() {
  group('HistoryEntry', () {
    final now = DateTime(2026, 4, 12, 14, 0);

    test('reference returns "BookName chapter"', () {
      final entry = HistoryEntry(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 3,
        bibleId: 'kjv',
        readAt: now,
      );
      expect(entry.reference, 'Genesis 3');
    });

    test('toJson round-trips through fromJson', () {
      final original = HistoryEntry(
        bookId: 'REV',
        bookName: 'Revelation',
        chapter: 21,
        bibleId: 'web',
        readAt: now,
      );
      final json = original.toJson();
      final restored = HistoryEntry.fromJson(json);

      expect(restored.bookId, original.bookId);
      expect(restored.bookName, original.bookName);
      expect(restored.chapter, original.chapter);
      expect(restored.bibleId, original.bibleId);
      expect(restored.readAt.toIso8601String(), original.readAt.toIso8601String());
    });

    test('fromJson handles missing fields', () {
      final entry = HistoryEntry.fromJson({});
      expect(entry.bookId, '');
      expect(entry.bookName, '');
      expect(entry.chapter, 0);
      expect(entry.bibleId, 'kjv');
    });

    test('fromJson with invalid date falls back to now', () {
      final entry = HistoryEntry.fromJson({'readAt': 'not-a-date'});
      // Should not throw, falls back to DateTime.now()
      expect(entry.readAt, isNotNull);
    });
  });
}
