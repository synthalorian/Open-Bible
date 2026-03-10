import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenealogyPage extends StatefulWidget {
  const GenealogyPage({super.key});

  @override
  State<GenealogyPage> createState() => _GenealogyPageState();
}

class _GenealogyPageState extends State<GenealogyPage> {
  List<GenealogyPerson> _people = [];
  bool _isLoading = true;
  GenealogyPerson? _selectedPerson;

  @override
  void initState() {
    super.initState();
    _loadGenealogyData();
  }

  Future<void> _loadGenealogyData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/genealogy_data.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _people = jsonData.map((json) => GenealogyPerson.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading genealogy data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblical Genealogy'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _people.isEmpty
              ? const Center(child: Text('No genealogy data available'))
              : Column(
                  children: [
                    Expanded(
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.1,
                        maxScale: 3.0,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: _buildTreeView(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedPerson != null)
                      _buildPersonDetails(),
                  ],
                ),
    );
  }

  Widget _buildTreeView() {
    // Group people by generation
    final generations = <int, List<GenealogyPerson>>{};
    for (final person in _people) {
      generations.putIfAbsent(person.generation, () => []).add(person);
    }

    final sortedGenerations = generations.keys.toList()..sort();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Adam to Abraham Lineage',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...sortedGenerations.map((gen) => _buildGenerationRow(generations[gen]!, gen)),
        ],
      ),
    );
  }

  Widget _buildGenerationRow(List<GenealogyPerson> people, int generation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$generation',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ...people.map((person) => _buildPersonCard(person)),
        ],
      ),
    );
  }

  Widget _buildPersonCard(GenealogyPerson person) {
    final isSelected = _selectedPerson?.id == person.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPerson = isSelected ? null : person;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              person.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (person.title.isNotEmpty)
              Text(
                person.title,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            if (person.birthYear != null)
              Text(
                'b. ${person.birthYear}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonDetails() {
    final person = _selectedPerson!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                person.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedPerson = null),
              ),
            ],
          ),
          if (person.title.isNotEmpty)
            Text(
              person.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          const SizedBox(height: 8),
          if (person.description.isNotEmpty)
            Text(
              person.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 8),
          Text(
            'Scripture: ${person.scripture}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          if (person.birthYear != null)
            Text(
              'Lived: ${person.birthYear} - ${person.deathYear ?? '?'} (${person.deathYear != null ? person.deathYear! - person.birthYear! : '?'} years)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class GenealogyPerson {
  final String id;
  final String name;
  final String title;
  final int? birthYear;
  final int? deathYear;
  final String scripture;
  final String description;
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
    required this.description,
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
      description: json['description'] ?? '',
      children: List<String>.from(json['children'] ?? []),
      testament: json['Testament'] ?? 'old',
      generation: json['generation'] ?? 0,
      parent: json['parent'],
    );
  }
}
