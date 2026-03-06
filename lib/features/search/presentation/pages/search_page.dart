import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/bible_search_service.dart';
import '../../../../core/services/current_bible.dart';
import '../../../../core/config/bible_translations.dart';

/// Search page for finding Bible verses
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  String _selectedBibleId = 'kjv';
  int _resultCount = 50;

  @override
  void initState() {
    super.initState();
    _selectedBibleId = CurrentBible.id;
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await BibleSearchService.search(
        query,
        bibleId: _selectedBibleId,
        maxResults: _resultCount,
      );

      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bible'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSearchOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for verses (e.g., "love", "John 3:16")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _results = []);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {});
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              onSubmitted: _performSearch,
            ),
          ),

          // Current Bible indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Searching in: ${BibleTranslations.getAbbreviation(_selectedBibleId)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_results.isNotEmpty)
                  Text(
                    '${_results.length} results',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search the Bible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for "love", "faith",\nor jump to "John 3:16"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          // Quick search suggestions
          Wrap(
            spacing: 8,
            children: [
              _buildQuickSearchChip('love'),
              _buildQuickSearchChip('faith'),
              _buildQuickSearchChip('hope'),
              _buildQuickSearchChip('grace'),
              _buildQuickSearchChip('peace'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String term) {
    return ActionChip(
      label: Text(term),
      onPressed: () {
        _searchController.text = term;
        _performSearch(term);
      },
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _openVerse(result),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference
              Row(
                children: [
                  Text(
                    result.reference,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    BibleTranslations.getAbbreviation(result.bibleId),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Verse text
              Text(
                result.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.bookmark_outline, size: 18),
                    label: const Text('Save'),
                    onPressed: () => _saveVerse(result),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    onPressed: () => _shareVerse(result),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Bible selection
              Text('Translation:', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBibleId,
                items: BibleTranslations.all.map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text('${t.abbreviation} - ${t.fullName}'),
                )).toList(),
                onChanged: (value) {
                  setModalState(() => _selectedBibleId = value ?? 'kjv');
                  setState(() => _selectedBibleId = value ?? 'kjv');
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Result count
              Text('Max results:', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              Slider(
                value: _resultCount.toDouble(),
                min: 10,
                max: 200,
                divisions: 19,
                label: _resultCount.toString(),
                onChanged: (value) {
                  setModalState(() => _resultCount = value.round());
                  setState(() => _resultCount = value.round());
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openVerse(SearchResult result) {
    // Navigate to the chapter
    context.push('/bible/book/${result.bookId}/chapter/${result.chapter}');
  }

  void _saveVerse(SearchResult result) {
    // TODO: Implement save/bookmark
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ${result.reference}')),
    );
  }

  void _shareVerse(SearchResult result) {
    // TODO: Implement share
    final text = '${result.reference}\n\n${result.text}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: ${result.reference}')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
