import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DictionaryEntry {
  final String term;
  final String definition;

  DictionaryEntry({required this.term, required this.definition});

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      term: json['term'],
      definition: json['definition'],
    );
  }
}

class BibleDictionaryPage extends StatefulWidget {
  const BibleDictionaryPage({super.key});

  @override
  State<BibleDictionaryPage> createState() => _BibleDictionaryPageState();
}

class _BibleDictionaryPageState extends State<BibleDictionaryPage> {
  List<DictionaryEntry> entries = [];
  List<DictionaryEntry> filteredEntries = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/bible_dictionary.json');
      final jsonData = json.decode(jsonString);
      final List<dynamic> entriesList = jsonData['entries'];
      
      setState(() {
        entries = entriesList.map((e) => DictionaryEntry.fromJson(e)).toList()
          ..sort((a, b) => a.term.compareTo(b.term));
        filteredEntries = entries;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load dictionary entries: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterEntries(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredEntries = entries;
      } else {
        filteredEntries = entries.where((e) =>
          e.term.toLowerCase().contains(query.toLowerCase()) ||
          e.definition.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  void _showAlphabeticalIndex() {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jump to Letter', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: letters.map((letter) {
                final hasEntries = entries.any((e) => 
                  e.term.toUpperCase().startsWith(letter));
                return ActionChip(
                  label: Text(letter),
                  onPressed: hasEntries ? () {
                    Navigator.pop(context);
                    _scrollToLetter(letter);
                  } : null,
                  backgroundColor: hasEntries ? Colors.blue.shade100 : Colors.grey.shade200,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToLetter(String letter) {
    final index = filteredEntries.indexWhere((e) => 
      e.term.toUpperCase().startsWith(letter));
    if (index != -1) {
      // Would scroll to index in a real implementation
      setState(() {
        searchQuery = letter;
        _filterEntries(letter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bible Dictionary')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Dictionary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: _showAlphabeticalIndex,
            tooltip: 'Alphabetical Index',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search terms...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _filterEntries('');
                      },
                    )
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _filterEntries,
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredEntries.length} of ${entries.length} terms',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Entries list
          Expanded(
            child: filteredEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            entry.term[0],
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                        title: Text(
                          entry.term,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              entry.definition,
                              style: const TextStyle(fontSize: 15, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAlphabeticalIndex,
        child: const Icon(Icons.abc),
        tooltip: 'Alphabetical Index',
      ),
    );
  }
}
