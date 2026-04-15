import 'package:flutter_test/flutter_test.dart';
import 'package:open_bible/features/genealogy/services/genealogy_service.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GenealogyService Tests', () {
    late GenealogyService service;

    setUp(() {
      service = GenealogyService();
    });

    test('Data should load and have Adam and Jesus', () async {
      // Manual load since rootBundle isn't fully mocked in unit tests easily
      final String jsonString = await rootBundle.loadString('assets/data/genealogy_comprehensive.json');
      expect(jsonString, isNotEmpty);
      
      await service.load();
      final people = service.getAllPeople();
      
      expect(people.any((p) => p.id == 'adam'), isTrue);
      expect(people.any((p) => p.id == 'jesus'), isTrue);
    });

    test('Lineage from Adam to Jesus should be traversable', () async {
      await service.load();
      final lineage = service.getLineageToPerson('jesus');
      
      expect(lineage.first.id, equals('adam'));
      expect(lineage.last.id, equals('jesus'));
      expect(lineage.length, greaterThan(50)); // Based on our update
    });

    test('Immediate family lookup', () async {
      await service.load();
      final family = service.getImmediateFamily('isaac');
      
      // Isaac's parent is Abraham
      expect(family.any((p) => p.id == 'abraham'), isTrue);
      // Isaac's children are Jacob and Esau
      expect(family.any((p) => p.id == 'jacob'), isTrue);
      expect(family.any((p) => p.id == 'esau'), isTrue);
    });

    test('Search functionality', () async {
      await service.load();
      final results = service.search('David');
      
      expect(results.any((p) => p.name == 'David'), isTrue);
    });
  });
}
