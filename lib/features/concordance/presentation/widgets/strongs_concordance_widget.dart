import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

/// Strong's Concordance widget for Greek/Hebrew word lookup
class StrongsConcordanceWidget extends ConsumerWidget {
  const StrongsConcordanceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concordanceState = ref.watch(strongsConcordanceProvider);
    
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter Strong\'s number (e.g., H430, G26)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: concordanceState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                ref.read(strongsConcordanceProvider.notifier).lookupWord(value.trim());
              }
            },
          ),
        ),
        
        // Error message
        if (concordanceState.error != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    concordanceState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => ref.read(strongsConcordanceProvider.notifier).clearError(),
                ),
              ],
            ),
          ),
        ],
        
        // Search result
        if (concordanceState.currentEntry != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => ref.read(strongsConcordanceProvider.notifier).clearSelection(),
                icon: const Icon(Icons.close),
                label: const Text('Close result'),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: StrongsEntryCard(entry: concordanceState.currentEntry!),
            ),
          ),
        ],
        
        // Empty state
        if (concordanceState.currentEntry == null && !concordanceState.isLoading && concordanceState.error == null) ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Strong\'s Concordance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Search by Strong\'s number or word',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'H430', 'G26', 'H1', 'G3056', 'G1'
                    ].map((number) => ActionChip(
                      label: Text(number),
                      onPressed: () {
                        ref.read(strongsConcordanceProvider.notifier).lookupWord(number);
                      },
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Strong's entry card
class StrongsEntryCard extends ConsumerWidget {
  final StrongsEntry entry;
  
  const StrongsEntryCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(strongsConcordanceProvider.notifier).isFavorite(entry.number);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with number and favorite
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: entry.language == 'hebrew'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: entry.language == 'hebrew'
                          ? Colors.blue
                          : Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    entry.language.toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: entry.language == 'hebrew'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.purple.withOpacity(0.1),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    ref.read(strongsConcordanceProvider.notifier).toggleFavorite(entry);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Original word
            Center(
              child: Text(
                entry.word,
                style: const TextStyle(
                  fontSize: 48,
                  fontFamily: 'serif',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Transliteration
            Center(
              child: Text(
                entry.transliteration,
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            // Pronunciation
            Center(
              child: Text(
                '[${entry.pronunciation}]',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            // Definition
            Text(
              'Definition',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.definition,
              style: const TextStyle(fontSize: 18),
            ),
            
            // Extended definition
            if (entry.extendedDefinition != null) ...[
              const SizedBox(height: 16),
              Text(
                entry.extendedDefinition!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            // Bible verses
            if (entry.verses.isNotEmpty) ...[
              Text(
                'Bible References',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.verses.map((verse) {
                  return ActionChip(
                    label: Text(verse),
                    onPressed: () {
                      // Navigate to verse would go here
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact Strong's search button
class CompactStrongsButton extends StatelessWidget {
  const CompactStrongsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_book),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.only(top: 16),
                child: const StrongsConcordanceWidget(),
              );
            },
          ),
        );
      },
      tooltip: 'Strong\'s Concordance',
    );
  }
}

/// Strong's favorites list
class StrongsFavoritesList extends ConsumerWidget {
  const StrongsFavoritesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(strongsConcordanceProvider).favorites;
    
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'No favorites yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final entry = favorites[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: entry.language == 'hebrew'
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                entry.number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: entry.language == 'hebrew'
                      ? Colors.blue
                      : Colors.purple,
                ),
              ),
            ),
          ),
          title: Text(entry.word),
          subtitle: Text(entry.definition),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              ref.read(strongsConcordanceProvider.notifier).toggleFavorite(entry);
            },
          ),
          onTap: () {
            ref.read(strongsConcordanceProvider.notifier).lookupWord(entry.number);
          },
        );
      },
    );
  }
}

/// Recent Strong's searches
class StrongsRecentSearches extends ConsumerWidget {
  const StrongsRecentSearches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearches = ref.watch(strongsConcordanceProvider).recentSearches;
    
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final entry = recentSearches[index];
              return Card(
                margin: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    ref.read(strongsConcordanceProvider.notifier).lookupWord(entry.number);
                  },
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.number,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.definition,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
