import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/current_bible.dart';
import '../../../bible/presentation/pages/chapter_reader_page.dart';

/// Full-text search page
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Request focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bibleSearchProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search the Bible...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(bibleSearchProvider.notifier).clearResults();
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 18),
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            ref.read(bibleSearchProvider.notifier).updateQuery(value);
            setState(() {}); // Update suffix icon visibility
          },
          onSubmitted: (_) {
            ref.read(bibleSearchProvider.notifier).search();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: searchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchState.results.isNotEmpty
              ? _buildResultsList(searchState)
              : searchState.query.isNotEmpty
                  ? _buildEmptyState('No results found for "${searchState.query}"')
                  : recentSearches.isNotEmpty
                      ? _buildRecentSearches(recentSearches)
                      : _buildEmptyState('Enter a search term to find verses'),
    );
  }
  
  Widget _buildResultsList(BibleSearchState searchState) {
    return Column(
      children: [
        // Results header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                '${searchState.totalResults} results',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (searchState.filter.hasActiveFilters) ...[
                const SizedBox(width: 8),
                Chip(
                  label: const Text('Filtered'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
              const Spacer(),
              if (searchState.filter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    ref.read(bibleSearchProvider.notifier).updateFilter(const SearchFilter());
                  },
                  child: const Text('Clear filters'),
                ),
            ],
          ),
        ),
        
        // Results list
        Expanded(
          child: ListView.builder(
            itemCount: searchState.results.length,
            itemBuilder: (context, index) {
              final result = searchState.results[index];
              return _SearchResultCard(result: result);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentSearches(List<RecentSearch> searches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(recentSearchesProvider.notifier).clearAll();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final search = searches[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(search.query),
                subtitle: search.resultCount > 0
                    ? Text('${search.resultCount} results')
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(recentSearchesProvider.notifier).removeSearch(search.query);
                  },
                ),
                onTap: () {
                  _searchController.text = search.query;
                  ref.read(bibleSearchProvider.notifier).updateQuery(search.query);
                  ref.read(bibleSearchProvider.notifier).search();
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SearchFilterSheet(),
    );
  }
}

/// Search result card
class _SearchResultCard extends ConsumerWidget {
  final SearchResult result;
  
  const _SearchResultCard({required this.result});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToVerse(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Reference and Translation
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${result.bookName} ${result.chapter}:${result.verse}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.translationId.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Verse text with highlights
              RichText(
                text: TextSpan(
                  children: result.highlightedText,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToVerse(BuildContext context, WidgetRef ref) {
    // Set selected translation in both provider and global current Bible.
    ref.read(selectedTranslationProvider.notifier).state = result.translationId;
    CurrentBible.set(result.translationId);

    // ChapterReader expects slug-style book IDs (e.g., "genesis", "1 john").
    final normalizedBookId = _normalizeBookId(result.bookId, result.bookName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterReaderPage(
          bookId: normalizedBookId,
          chapter: result.chapter,
        ),
      ),
    );
  }

  String _normalizeBookId(String rawId, String fallbackName) {
    final id = rawId.trim().toLowerCase();
    // If provider result already has a slug-like id, keep it.
    if (id.contains(' ') || id.length > 4) return id;
    // For short/abbr ids (e.g., GEN, JHN), derive from book name.
    return fallbackName.trim().toLowerCase();
  }
}

/// Search filter bottom sheet
class SearchFilterSheet extends ConsumerStatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  ConsumerState<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends ConsumerState<SearchFilterSheet> {
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bibleSearchProvider);
    final filter = searchState.filter;
    final translations = availableTranslations; // This is a const list, not a provider
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(bibleSearchProvider.notifier).updateFilter(const SearchFilter());
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Testament filter
              _buildSectionTitle('Testament'),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Old Testament'),
                    selected: filter.oldTestamentOnly,
                    onSelected: (_) {
                      ref.read(bibleSearchProvider.notifier).updateFilter(
                        filter.copyWith(
                          oldTestamentOnly: !filter.oldTestamentOnly,
                          newTestamentOnly: false,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('New Testament'),
                    selected: filter.newTestamentOnly,
                    onSelected: (_) {
                      ref.read(bibleSearchProvider.notifier).updateFilter(
                        filter.copyWith(
                          newTestamentOnly: !filter.newTestamentOnly,
                          oldTestamentOnly: false,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Translations
              _buildSectionTitle('Translations'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: translations.map((translation) {
                  final isSelected = filter.selectedTranslations.contains(translation.id);
                  return FilterChip(
                    label: Text(translation.abbreviation),
                    selected: isSelected,
                    onSelected: (_) {
                      final newSet = Set<String>.from(filter.selectedTranslations);
                      if (isSelected) {
                        newSet.remove(translation.id);
                      } else {
                        newSet.add(translation.id);
                      }
                      ref.read(bibleSearchProvider.notifier).updateFilter(
                        filter.copyWith(selectedTranslations: newSet),
                      );
                    },
                  );
                }).toList(),
              ),
              
              const Spacer(),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
