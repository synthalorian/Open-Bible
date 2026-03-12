import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/footnote_service.dart';

/// Enhanced footnote bottom sheet with filtering and cross-references
class FootnoteBottomSheet extends ConsumerStatefulWidget {
  final String bookId;
  final int chapter;
  final int verse;
  final String verseText;
  final String verseId;
  
  const FootnoteBottomSheet({
    super.key,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.verseText,
    required this.verseId,
  });

  @override
  ConsumerState<FootnoteBottomSheet> createState() => _FootnoteBottomSheetState();
}

class _FootnoteBottomSheetState extends ConsumerState<FootnoteBottomSheet> {
  Set<FootnoteType> _selectedTypes = {};
  bool _showCrossReferences = true;
  
  @override
  Widget build(BuildContext context) {
    final footnoteService = ref.watch(footnoteServiceProvider);
    final footnotes = footnoteService.getFootnotes(widget.bookId, widget.chapter, widget.verse);
    final crossReferences = footnoteService.getCrossReferences(widget.bookId, widget.chapter, widget.verse);
    
    // Filter footnotes by selected types
    final filteredFootnotes = _selectedTypes.isEmpty
        ? footnotes
        : footnotes.where((f) => _selectedTypes.contains(f.type)).toList();
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Drag handle
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
                    // Verse reference
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getBookName(widget.bookId)} ${widget.chapter}:${widget.verse}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.verseText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Filter chips
              if (footnotes.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Type filters
                        ...FootnoteType.values.map((type) {
                          final isSelected = _selectedTypes.contains(type);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_getTypeLabel(type)),
                              selected: isSelected,
                              onSelected: (_) => _toggleType(type),
                              avatar: Icon(
                                _getTypeIcon(type),
                                size: 16,
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : _getTypeColor(type),
                              ),
                              selectedColor: _getTypeColor(type),
                              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                              labelStyle: TextStyle(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                              ),
                            ),
                          );
                        }),
                        // Cross-references toggle
                        if (crossReferences.isNotEmpty)
                          FilterChip(
                            label: const Text('Cross-refs'),
                            selected: _showCrossReferences,
                            onSelected: (_) => setState(() => _showCrossReferences = !_showCrossReferences),
                            avatar: Icon(
                              Icons.link,
                              size: 16,
                              color: _showCrossReferences 
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            selectedColor: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Content
              Expanded(
                child: footnotes.isEmpty && crossReferences.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Footnotes section
                          if (filteredFootnotes.isNotEmpty) ...[
                            _buildSectionHeader('Footnotes (${filteredFootnotes.length})'),
                            const SizedBox(height: 12),
                            ...filteredFootnotes.asMap().entries.map((entry) {
                              return _buildFootnoteCard(entry.value, entry.key + 1);
                            }),
                          ],
                          
                          // Cross-references section
                          if (_showCrossReferences && crossReferences.isNotEmpty) ...[
                            if (filteredFootnotes.isNotEmpty) const SizedBox(height: 24),
                            _buildSectionHeader('Cross References (${crossReferences.length})'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: crossReferences.map((ref) {
                                return ActionChip(
                                  avatar: const Icon(Icons.open_in_new, size: 16),
                                  label: Text(ref.reference),
                                  onPressed: () => _navigateToCrossReference(ref),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No footnotes available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This verse has no additional notes or cross-references.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFootnoteCard(Footnote footnote, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getTypeColor(footnote.type).withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with number and type
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getTypeColor(footnote.type),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(footnote.type).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(footnote.type),
                        size: 12,
                        color: _getTypeColor(footnote.type),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTypeLabel(footnote.type),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(footnote.type),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Footnote text
            Text(
              footnote.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _toggleType(FootnoteType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }
  
  void _navigateToCrossReference(CrossReference ref) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cross-reference: ${ref.reference}')),
    );
  }
  
  String _getBookName(String bookId) {
    // Map book IDs to names
    final bookNames = {
      'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus',
      'NUM': 'Numbers', 'DEU': 'Deuteronomy', 'JOS': 'Joshua',
      'JDG': 'Judges', 'RUT': 'Ruth', '1SA': '1 Samuel',
      '2SA': '2 Samuel', '1KI': '1 Kings', '2KI': '2 Kings',
      '1CH': '1 Chronicles', '2CH': '2 Chronicles', 'EZR': 'Ezra',
      'NEH': 'Nehemiah', 'EST': 'Esther', 'JOB': 'Job',
      'PSA': 'Psalms', 'PRO': 'Proverbs', 'ECC': 'Ecclesiastes',
      'SNG': 'Song of Solomon', 'ISA': 'Isaiah', 'JER': 'Jeremiah',
      'LAM': 'Lamentations', 'EZK': 'Ezekiel', 'DAN': 'Daniel',
      'HOS': 'Hosea', 'JOL': 'Joel', 'AMO': 'Amos',
      'OBA': 'Obadiah', 'JON': 'Jonah', 'MIC': 'Micah',
      'NAM': 'Nahum', 'HAB': 'Habakkuk', 'ZEP': 'Zephaniah',
      'HAG': 'Haggai', 'ZEC': 'Zechariah', 'MAL': 'Malachi',
      'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke',
      'JHN': 'John', 'ACT': 'Acts', 'ROM': 'Romans',
      '1CO': '1 Corinthians', '2CO': '2 Corinthians', 'GAL': 'Galatians',
      'EPH': 'Ephesians', 'PHP': 'Philippians', 'COL': 'Colossians',
      '1TH': '1 Thessalonians', '2TH': '2 Thessalonians', '1TI': '1 Timothy',
      '2TI': '2 Timothy', 'TIT': 'Titus', 'PHM': 'Philemon',
      'HEB': 'Hebrews', 'JAS': 'James', '1PE': '1 Peter',
      '2PE': '2 Peter', '1JN': '1 John', '2JN': '2 John',
      '3JN': '3 John', 'JUD': 'Jude', 'REV': 'Revelation',
    };
    return bookNames[bookId] ?? bookId;
  }
  
  String _getTypeLabel(FootnoteType type) {
    switch (type) {
      case FootnoteType.general:
        return 'General';
      case FootnoteType.linguistic:
        return 'Linguistic';
      case FootnoteType.translation:
        return 'Translation';
      case FootnoteType.theological:
        return 'Theological';
      case FootnoteType.historical:
        return 'Historical';
      case FootnoteType.cultural:
        return 'Cultural';
      case FootnoteType.interpretation:
        return 'Interpretation';
      case FootnoteType.crossReference:
        return 'Cross-ref';
      case FootnoteType.messianic:
        return 'Messianic';
    }
  }
  
  IconData _getTypeIcon(FootnoteType type) {
    switch (type) {
      case FootnoteType.general:
        return Icons.notes;
      case FootnoteType.linguistic:
        return Icons.language;
      case FootnoteType.translation:
        return Icons.translate;
      case FootnoteType.theological:
        return Icons.church;
      case FootnoteType.historical:
        return Icons.history;
      case FootnoteType.cultural:
        return Icons.people;
      case FootnoteType.interpretation:
        return Icons.lightbulb;
      case FootnoteType.crossReference:
        return Icons.link;
      case FootnoteType.messianic:
        return Icons.star;
    }
  }
  
  Color _getTypeColor(FootnoteType type) {
    switch (type) {
      case FootnoteType.general:
        return Colors.grey;
      case FootnoteType.linguistic:
        return Colors.teal;
      case FootnoteType.translation:
        return Colors.blue;
      case FootnoteType.theological:
        return Colors.purple;
      case FootnoteType.historical:
        return Colors.brown;
      case FootnoteType.cultural:
        return Colors.orange;
      case FootnoteType.interpretation:
        return Colors.amber;
      case FootnoteType.crossReference:
        return Colors.indigo;
      case FootnoteType.messianic:
        return Colors.red;
    }
  }
}

/// Provider for footnote service
final footnoteServiceProvider = Provider<FootnoteService>((ref) {
  return FootnoteService();
});
