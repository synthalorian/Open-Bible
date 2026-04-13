import 'package:flutter_test/flutter_test.dart';
import 'package:open_bible/core/providers/app_providers.dart';

void main() {
  group('AppSettings', () {
    test('default values are correct', () {
      const settings = AppSettings();
      expect(settings.selectedBibleId, 'kjv');
      expect(settings.fontSize, 18);
      expect(settings.readingMode, ReadingMode.day);
      expect(settings.isDarkMode, false);
      expect(settings.notificationsEnabled, true);
      expect(settings.dailyVerseNotifications, true);
      expect(settings.dailyVerseTime.hour, 8);
      expect(settings.dailyVerseTime.minute, 0);
      expect(settings.audioEnabled, true);
      expect(settings.isLoaded, false);
    });

    test('copyWith replaces only specified fields', () {
      const original = AppSettings();
      final modified = original.copyWith(
        fontSize: 24,
        readingMode: ReadingMode.night,
        isDarkMode: true,
      );
      expect(modified.fontSize, 24);
      expect(modified.readingMode, ReadingMode.night);
      expect(modified.isDarkMode, true);
      // Unchanged fields
      expect(modified.selectedBibleId, 'kjv');
      expect(modified.notificationsEnabled, true);
      expect(modified.audioEnabled, true);
      expect(modified.isLoaded, false);
    });

    test('copyWith with no arguments preserves all values', () {
      const original = AppSettings(
        selectedBibleId: 'web',
        fontSize: 22,
        readingMode: ReadingMode.sepia,
      );
      final copy = original.copyWith();
      expect(copy.selectedBibleId, 'web');
      expect(copy.fontSize, 22);
      expect(copy.readingMode, ReadingMode.sepia);
    });

    test('copyWith can set isLoaded', () {
      const settings = AppSettings();
      expect(settings.isLoaded, false);
      final loaded = settings.copyWith(isLoaded: true);
      expect(loaded.isLoaded, true);
    });

    test('daily verse time copyWith', () {
      const original = AppSettings();
      final modified = original.copyWith(
        dailyVerseTime: const DailyVerseTime(hour: 20, minute: 30),
      );
      expect(modified.dailyVerseTime.hour, 20);
      expect(modified.dailyVerseTime.minute, 30);
    });
  });

  group('ReadingMode', () {
    test('has 4 modes', () {
      expect(ReadingMode.values.length, 4);
    });

    test('day is index 0', () {
      expect(ReadingMode.day.index, 0);
    });

    test('night is index 1', () {
      expect(ReadingMode.night.index, 1);
    });

    test('sepia is index 2', () {
      expect(ReadingMode.sepia.index, 2);
    });

    test('amoled is index 3', () {
      expect(ReadingMode.amoled.index, 3);
    });
  });

  group('ReadingPositionData', () {
    test('defaults to Genesis 1:1', () {
      final pos = ReadingPositionData();
      expect(pos.bookId, 'GEN');
      expect(pos.chapter, 1);
      expect(pos.verse, 1);
    });

    test('copyWith replaces fields', () {
      final pos = ReadingPositionData();
      final updated = pos.copyWith(bookId: 'REV', chapter: 22, verse: 21);
      expect(updated.bookId, 'REV');
      expect(updated.chapter, 22);
      expect(updated.verse, 21);
    });

    test('copyWith partial update preserves other fields', () {
      final pos = ReadingPositionData(bookId: 'PSA', chapter: 119, verse: 105);
      final updated = pos.copyWith(chapter: 23);
      expect(updated.bookId, 'PSA');
      expect(updated.chapter, 23);
      expect(updated.verse, 105);
    });
  });

  group('BibleTranslation', () {
    test('availableTranslations has 14 entries', () {
      expect(availableTranslations.length, 14);
    });

    test('first translation is KJV', () {
      expect(availableTranslations.first.id, 'kjv');
      expect(availableTranslations.first.abbreviation, 'KJV');
    });

    test('all translations have required fields', () {
      for (final t in availableTranslations) {
        expect(t.id, isNotEmpty);
        expect(t.name, isNotEmpty);
        expect(t.abbreviation, isNotEmpty);
        expect(t.language, 'English');
      }
    });

    test('all translation IDs are unique', () {
      final ids = availableTranslations.map((t) => t.id).toSet();
      expect(ids.length, availableTranslations.length);
    });
  });

  group('ReadingPosition', () {
    test('default verse is 1', () {
      final pos = ReadingPosition(bookId: 'GEN', chapter: 1);
      expect(pos.verse, 1);
    });

    test('custom verse is preserved', () {
      final pos = ReadingPosition(bookId: 'JHN', chapter: 3, verse: 16);
      expect(pos.bookId, 'JHN');
      expect(pos.chapter, 3);
      expect(pos.verse, 16);
    });
  });
}
