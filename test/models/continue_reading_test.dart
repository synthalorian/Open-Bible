import 'package:flutter_test/flutter_test.dart';
import 'package:open_bible/core/services/continue_reading_service.dart';

void main() {
  group('ContinueReadingData', () {
    test('reference returns "BookName chapter"', () {
      const data = ContinueReadingData(
        bookId: 'PSA',
        bookName: 'Psalms',
        chapter: 23,
        bibleId: 'kjv',
        bibleName: 'King James Version',
      );
      expect(data.reference, 'Psalms 23');
    });

    test('timeAgo returns empty string when lastRead is null', () {
      const data = ContinueReadingData(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 1,
        bibleId: 'kjv',
        bibleName: 'King James Version',
      );
      expect(data.timeAgo, '');
    });

    test('timeAgo returns "Just now" for very recent', () {
      final data = ContinueReadingData(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 1,
        bibleId: 'kjv',
        bibleName: 'King James Version',
        lastRead: DateTime.now().subtract(const Duration(seconds: 30)),
      );
      expect(data.timeAgo, 'Just now');
    });

    test('timeAgo returns minutes for < 1 hour', () {
      final data = ContinueReadingData(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 1,
        bibleId: 'kjv',
        bibleName: 'King James Version',
        lastRead: DateTime.now().subtract(const Duration(minutes: 25)),
      );
      expect(data.timeAgo, '25m ago');
    });

    test('timeAgo returns hours for < 1 day', () {
      final data = ContinueReadingData(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 1,
        bibleId: 'kjv',
        bibleName: 'King James Version',
        lastRead: DateTime.now().subtract(const Duration(hours: 5)),
      );
      expect(data.timeAgo, '5h ago');
    });

    test('timeAgo returns days for < 1 week', () {
      final data = ContinueReadingData(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 1,
        bibleId: 'kjv',
        bibleName: 'King James Version',
        lastRead: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(data.timeAgo, '3d ago');
    });

    test('timeAgo returns weeks for >= 7 days', () {
      final data = ContinueReadingData(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 1,
        bibleId: 'kjv',
        bibleName: 'King James Version',
        lastRead: DateTime.now().subtract(const Duration(days: 14)),
      );
      expect(data.timeAgo, '2w ago');
    });

    test('default versePosition is 0', () {
      const data = ContinueReadingData(
        bookId: 'GEN',
        bookName: 'Genesis',
        chapter: 1,
        bibleId: 'kjv',
        bibleName: 'King James Version',
      );
      expect(data.versePosition, 0);
    });
  });
}
