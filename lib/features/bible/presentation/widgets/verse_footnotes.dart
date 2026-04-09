import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/footnote_service.dart';

/// Footnote service provider
final _footnoteServiceProvider = Provider<FootnoteService>((ref) => FootnoteService());

class VerseFootnotes extends ConsumerWidget {
  final String bookId;
  final int chapter;
  final int verse;
  final Function(String reference)? onReferenceTap;

  const VerseFootnotes({
    super.key,
    required this.bookId,
    required this.chapter,
    required this.verse,
    this.onReferenceTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footnoteService = ref.watch(_footnoteServiceProvider);
    final footnotes = footnoteService.getFootnotes(bookId, chapter, verse);
    final crossRefs = footnoteService.getCrossReferences(bookId, chapter, verse);
    
    if (footnotes.isEmpty && crossRefs.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 34),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study notes
          ...footnotes.map((footnote) => _buildStudyNote(context, footnote)),
          
          // Cross references
          if (crossRefs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: crossRefs.map((ref) => _buildCrossReferenceChip(context, ref)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudyNote(BuildContext context, Footnote footnote) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.menu_book,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              footnote.text,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrossReferenceChip(BuildContext context, CrossReference crossRef) {
    return ActionChip(
      avatar: Icon(
        Icons.link,
        size: 12,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(
        crossRef.reference,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: () {
        if (onReferenceTap != null) {
          onReferenceTap!(crossRef.reference);
        }
      },
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
    );
  }
}
