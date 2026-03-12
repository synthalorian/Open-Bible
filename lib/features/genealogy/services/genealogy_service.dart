import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for loading and managing genealogy data
class GenealogyService {
  static final GenealogyService _instance = GenealogyService._internal();
  factory GenealogyService() => _instance;
  GenealogyService._internal();

  List<GenealogyPerson> _people = [];
  bool _isLoaded = false;

  /// Load genealogy data from JSON
  Future<void> load() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/genealogy_comprehensive.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      _people = jsonData.map((json) => GenealogyPerson.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading genealogy data: $e');
      _people = [];
    }
  }

  /// Get all people
  List<GenealogyPerson> getAllPeople() => List.unmodifiable(_people);

  /// Get person by ID
  GenealogyPerson? getPerson(String id) {
    try {
      return _people.firstWhere((p) => p.id == id);
    } catch (e) {
      debugPrint('Failed to find person by ID: $e');
      return null;
    }
  }

  /// Get children of a person
  List<GenealogyPerson> getChildren(String parentId) {
    return _people.where((p) => p.parent == parentId).toList();
  }

  /// Get parent of a person
  GenealogyPerson? getParent(String childId) {
    final child = getPerson(childId);
    if (child?.parent != null) {
      return getPerson(child!.parent!);
    }
    return null;
  }

  /// Get all ancestors of a person
  List<GenealogyPerson> getAncestors(String personId) {
    final ancestors = <GenealogyPerson>[];
    String? currentId = personId;

    while (currentId != null) {
      final person = getPerson(currentId);
      if (person?.parent != null) {
        final parent = getPerson(person!.parent!);
        if (parent != null) {
          ancestors.add(parent);
          currentId = parent.id;
          continue;
        }
      }
      break;
    }

    return ancestors;
  }

  /// Get all descendants of a person
  List<GenealogyPerson> getDescendants(String personId) {
    final descendants = <GenealogyPerson>[];
    final children = getChildren(personId);

    for (final child in children) {
      descendants.add(child);
      descendants.addAll(getDescendants(child.id));
    }

    return descendants;
  }

  /// Get lineage from Adam to a person
  List<GenealogyPerson> getLineageToPerson(String personId) {
    final lineage = <GenealogyPerson>[];
    final ancestors = getAncestors(personId);
    
    // Add ancestors in reverse order (Adam first)
    lineage.addAll(ancestors.reversed);
    
    // Add the person
    final person = getPerson(personId);
    if (person != null) {
      lineage.add(person);
    }

    return lineage;
  }

  /// Get people by generation
  List<GenealogyPerson> getByGeneration(int generation) {
    return _people.where((p) => p.generation == generation).toList();
  }

  /// Get people by testament
  List<GenealogyPerson> getByTestament(String testament) {
    return _people.where((p) => p.testament == testament).toList();
  }

  /// Search people by name or title
  List<GenealogyPerson> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _people.where((p) =>
      p.name.toLowerCase().contains(lowerQuery) ||
      p.title.toLowerCase().contains(lowerQuery) ||
      p.description?.toLowerCase().contains(lowerQuery) == true
    ).toList();
  }

  /// Get patriarchs (key figures)
  List<GenealogyPerson> getPatriarchs() {
    return _people.where((p) => 
      ['adam', 'enoch', 'noah', 'abraham', 'isaac', 'jacob', 'david', 'solomon'].contains(p.id)
    ).toList();
  }

  /// Get lineage of Jesus (through both Mary and Joseph)
  List<GenealogyPerson> getLineageOfJesus() {
    final jesus = getPerson('jesus');
    if (jesus == null) return [];
    return getLineageToPerson('jesus');
  }

  /// Get the twelve tribes of Israel
  List<GenealogyPerson> getTwelveTribes() {
    return _people.where((p) => 
      ['reuben', 'simeon', 'levi', 'judah', 'issachar', 'zebulun', 
       'joseph', 'benjamin', 'dan', 'naphtali', 'gad', 'asher'].contains(p.id)
    ).toList();
  }
}

/// Model for a person in the genealogy
class GenealogyPerson {
  final String id;
  final String name;
  final String title;
  final int? birthYear; // Years from creation (or BC if negative for Jesus)
  final int? deathYear;
  final String scripture;
  final String? description;
  final List<String> children;
  final String testament;
  final int generation;
  final String? parent;

  GenealogyPerson({
    required this.id,
    required this.name,
    required this.title,
    this.birthYear,
    this.deathYear,
    required this.scripture,
    this.description,
    required this.children,
    required this.testament,
    required this.generation,
    this.parent,
  });

  factory GenealogyPerson.fromJson(Map<String, dynamic> json) {
    return GenealogyPerson(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      birthYear: json['birthYear'],
      deathYear: json['deathYear'],
      scripture: json['scripture'] ?? '',
      description: json['description'],
      children: List<String>.from(json['children'] ?? []),
      testament: json['Testament'] ?? 'old',
      generation: json['generation'] ?? 0,
      parent: json['parent'],
    );
  }

  /// Get formatted birth year
  String get formattedBirthYear {
    if (birthYear == null) return 'Unknown';
    if (testament == 'new') return '${birthYear!.abs()} AD';
    return 'Year $birthYear';
  }

  /// Get formatted death year
  String get formattedDeathYear {
    if (deathYear == null) return 'Unknown';
    if (testament == 'new') return '${deathYear!.abs()} AD';
    return 'Year $deathYear';
  }

  /// Get lifespan
  String get lifespan {
    if (birthYear == null) return '';
    if (deathYear == null) return 'b. $formattedBirthYear';
    final years = deathYear! - birthYear!;
    return '$formattedBirthYear - $formattedDeathYear ($years years)';
  }

  /// Check if this is a patriarch/key figure
  bool get isPatriarch {
    return ['adam', 'enoch', 'noah', 'abraham', 'isaac', 'jacob', 'joseph', 'david', 'solomon', 'jesus'].contains(id);
  }

  /// Check if this is one of the twelve tribes
  bool get isTribe {
    return ['reuben', 'simeon', 'levi', 'judah', 'issachar', 'zebulun', 
            'joseph', 'benjamin', 'dan', 'naphtali', 'gad', 'asher'].contains(id);
  }
}
