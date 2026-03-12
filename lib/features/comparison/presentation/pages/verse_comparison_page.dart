import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/comparison_provider.dart';

/// Verse comparison page - side-by-side translation comparison
class VerseComparisonPage extends ConsumerStatefulWidget {
  final String? initialBookId;
  final String? initialBookName;
  final int? initialChapter;
  final int? initialVerse;
  final String? initialVerseText;

  const VerseComparisonPage({
    super.key,
    this.initialBookId,
    this.initialBookName,
    this.initialChapter,
    this.initialVerse,
    this.initialVerseText,
  });

  @override
  ConsumerState<VerseComparisonPage> createState() => _VerseComparisonPageState();
}

class _VerseComparisonPageState extends ConsumerState<VerseComparisonPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialBookId != null) {
        ref.read(verseComparisonProvider.notifier).setVerse(
          widget.initialBookId!,
          widget.initialBookName ?? widget.initialBookId!,
          widget.initialChapter ?? 1,
          widget.initialVerse ?? 1,
          widget.initialVerseText ?? '',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final comparisonState = ref.watch(verseComparisonProvider);
    final comparisons = comparisonState.comparisons;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${comparisonState.bookName} ${comparisonState.chapter}:${comparisonState.verse}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Compare Translations',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showTranslationSelector(context),
          ),
        ],
      ),
      body: comparisonState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : comparisons.isEmpty
              ? _buildEmptyState()
              : _buildComparisonList(comparisons),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a verse to compare',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose translations to compare side-by-side',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonList(List<TranslationComparison> comparisons) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: comparisons.length,
      itemBuilder: (context, index) {
        final comparison = comparisons[index];
        final isPrimary = comparison.isPrimary;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isPrimary ? 2 : 0,
          color: isPrimary 
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha:0.3)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Translation header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        comparison.translationAbbreviation,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPrimary
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        comparison.translationName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isPrimary)
                      Chip(
                        label: const Text('Primary'),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Verse text
                Text(
                  comparison.text,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTranslationSelector(BuildContext context) {
    final comparisonState = ref.read(verseComparisonProvider);
    final translations = availableTranslations;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha:0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Select Translations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose which translations to compare',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Translation list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: translations.length,
                    itemBuilder: (context, index) {
                      final translation = translations[index];
                      final isSelected = comparisonState.selectedTranslations.contains(translation.id);
                      
                      return CheckboxListTile(
                        title: Text(translation.name),
                        subtitle: Text(translation.abbreviation),
                        secondary: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            translation.abbreviation,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        value: isSelected,
                        onChanged: (_) {
                          ref.read(verseComparisonProvider.notifier).toggleTranslation(translation.id);
                        },
                      );
                    },
                  ),
                ),
                
                // Done button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
