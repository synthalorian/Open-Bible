import 'package:flutter/material.dart';
import '../../../../core/services/footnote_service.dart';

class VerseFootnotes extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FutureBuilder<List<Footnote>>(
      future: FootnoteService.getFootnotes(bookId, chapter, verse),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final footnotes = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(top: 8, left: 34),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: footnotes.map((footnote) => _buildFootnoteItem(context, footnote)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFootnoteItem(BuildContext context, Footnote footnote) {
    if (footnote.isCrossReference) {
      return _buildCrossReference(context, footnote);
    } else {
      return _buildStudyNote(context, footnote);
    }
  }

  Widget _buildCrossReference(BuildContext context, Footnote footnote) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          if (onReferenceTap != null && footnote.references.isNotEmpty) {
            onReferenceTap!(footnote.references.first);
          }
        },
        child: Row(
          children: [
            Icon(
              Icons.link,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                footnote.text,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              footnote.text,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
