import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bible illustration files are real JPEGs', () {
    final dir = Directory('assets/images/bible_illustrations');
    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.jpg'))
        .toList();
    expect(files, hasLength(25));
    for (final file in files) {
      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(10000), reason: file.path);
      expect(bytes[0], 0xFF, reason: file.path);
      expect(bytes[1], 0xD8, reason: file.path);
      expect(bytes[2], 0xFF, reason: file.path);
      expect(bytes[bytes.length - 2], 0xFF, reason: file.path);
      expect(bytes[bytes.length - 1], 0xD9, reason: file.path);
      expect(String.fromCharCodes(bytes.take(80)).toLowerCase().contains('<html'), isFalse);
    }
  });

  test('gallery paths point at real image files, including the repaired plates', () {
    final source = File(
      'lib/features/illustrations/presentation/pages/illustrations_gallery_page.dart',
    ).readAsStringSync();
    final paths = RegExp(r"imagePath: '([^']+)'")
        .allMatches(source)
        .map((match) => match.group(1)!)
        .toList();
    expect(paths, contains('assets/images/bible_illustrations/creation.jpg'));
    expect(paths, contains('assets/images/bible_illustrations/acts.jpg'));
    expect(paths, contains('assets/images/bible_illustrations/revelation.jpg'));
    for (final path in paths) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      final bytes = file.readAsBytesSync();
      final isImage = _isJpeg(bytes) || _isPng(bytes) || _isGif(bytes);
      expect(isImage, isTrue, reason: path);
    }
  });

  test('christian history image extensions match the file data', () {
    final dir = Directory('assets/data/christian_history/images');
    final files = dir.listSync().whereType<File>().toList();
    expect(files, isNotEmpty);
    for (final file in files) {
      final bytes = file.readAsBytesSync();
      if (file.path.endsWith('.jpg')) {
        expect(_isJpeg(bytes), isTrue, reason: file.path);
      } else if (file.path.endsWith('.png')) {
        expect(_isPng(bytes), isTrue, reason: file.path);
      } else if (file.path.endsWith('.gif')) {
        expect(_isGif(bytes), isTrue, reason: file.path);
      } else {
        fail('unexpected history image ${file.path}');
      }
    }
  });

  test('map assets are real PNGs registered for the five map ids', () {
    const expected = [
      'assets/maps/holy_land.png',
      'assets/maps/abraham_journey.png',
      'assets/maps/exodus_route.png',
      'assets/maps/jesus_ministry.png',
      'assets/maps/paul_journeys.png',
    ];
    final provider = File('lib/features/maps_charts/data/maps_charts_provider.dart').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/maps/'));
    for (final path in expected) {
      expect(provider, contains(path));
      final bytes = File(path).readAsBytesSync();
      expect(_isPng(bytes), isTrue, reason: path);
      expect(bytes.length, greaterThan(10000), reason: path);
    }
  });
}

bool _isJpeg(List<int> bytes) =>
    bytes.length > 4 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;

bool _isPng(List<int> bytes) =>
    bytes.length > 8 &&
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x4E &&
    bytes[3] == 0x47;

bool _isGif(List<int> bytes) =>
    bytes.length > 6 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46;
