import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_bible/core/config/bible_translations.dart';
import 'package:open_bible/core/services/bible_book_resolver.dart';

void main() {
  test('aliases are exact, so Jude is not Judges and John is not 1 John', () {
    final index = bibleBookAliasIndexForTest();
    expect(index['jud'], 'JUD');
    expect(index['jude'], 'JUD');
    expect(index['jdg'], 'JDG');
    expect(index['judges'], 'JDG');
    expect(index['jhn'], 'JHN');
    expect(index['john'], 'JHN');
    expect(index['1jn'], '1JN');
    expect(index['1john'], '1JN');
    expect(index['php'], 'PHP');
    expect(index['phm'], 'PHM');
    expect(index['philippians'], 'PHP');
    expect(index['philemon'], 'PHM');
    expect(resolveBibleBook('JUD')!.name, 'Jude');
    expect(resolveBibleBook('Judges')!.usfm, 'JDG');
    expect(resolveBibleBook('JHN')!.name, 'John');
    expect(resolveBibleBook('1JN')!.name, '1 John');
    expect(resolveBibleBook('1 John')!.usfm, '1JN');
    expect(resolveBibleBook('I John')!.usfm, '1JN');
    expect(resolveBibleBook('Song of Solomon')!.usfm, 'SNG');
    expect(resolveBibleBook('Song of Songs')!.usfm, 'SNG');
    expect(resolveBibleBook('2 Timothy')!.usfm, '2TI');
    expect(resolveBibleBook('not-a-book'), isNull);
    expect(resolveBibleBook('judg')!.usfm, 'JDG');
    expect(resolveBibleBook('judge'), isNull);
  });

  test('translation files use the configured asset name', () {
    expect(
      BibleTranslations.assetPath('geneva'),
      'assets/bible_data/gen_bible.json',
    );
    expect(
      BibleTranslations.assetPath('GENEVA'),
      'assets/bible_data/gen_bible.json',
    );
    expect(
      BibleTranslations.assetPath('kjv'),
      'assets/bible_data/kjv_bible.json',
    );
    expect(BibleTranslations.assetPath('missing'), isNull);
    for (final translation in BibleTranslations.all) {
      final path = BibleTranslations.assetPath(translation.id);
      expect(path, isNotNull);
      expect(File(path!).existsSync(), isTrue, reason: translation.id);
    }
  });

  test('USFM and full names resolve on every bundled translation', () {
    final probes = [
      'JUD',
      'JDG',
      'JHN',
      '1JN',
      '2JN',
      '3JN',
      'PHP',
      'PHM',
      '1SA',
      'SNG',
      'PSA',
      'John',
      '1 John',
      'Song of Solomon',
      '1 Corinthians',
    ];

    for (final translation in BibleTranslations.all) {
      final file = File(BibleTranslations.assetPath(translation.id)!);
      final bible = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final books = bible['books'] as List<dynamic>;
      expect(books, hasLength(66), reason: translation.id);

      for (final book in kBibleBooks) {
        for (final query in [book.usfm, book.name]) {
          final found = findBibleBook(books, query);
          expect(found, isNotNull, reason: '${translation.id} $query');
          expect(found!['name'], book.name, reason: '${translation.id} $query');
          final resolvedId = resolveBibleBook(found['id'].toString());
          expect(resolvedId!.usfm, book.usfm, reason: '${translation.id} ${found['id']}');
        }
      }

      for (final query in probes) {
        final want = resolveBibleBook(query)!;
        final found = findBibleBook(books, query);
        expect(found, isNotNull, reason: '${translation.id} $query');
        expect(found!['name'], want.name, reason: '${translation.id} $query');
      }

      final jude = findBibleBook(books, 'JUD')!;
      final judges = findBibleBook(books, 'JDG')!;
      expect(jude['name'], 'Jude');
      expect(judges['name'], 'Judges');
      expect(jude['id'], isNot(judges['id']));

      final john = findBibleBook(books, 'JHN')!;
      final firstJohn = findBibleBook(books, '1JN')!;
      expect(john['name'], 'John');
      expect(firstJohn['name'], '1 John');
      expect(normalizeBookKey(john['id'].toString()), isNot('1john'));
    }
  });
}
