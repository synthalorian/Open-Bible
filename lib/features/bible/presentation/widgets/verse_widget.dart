import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/verse_storage_service.dart';
import '../../../comparison/presentation/pages/verse_comparison_page.dart';
import 'footnote_bottom_sheet.dart';

/// Widget that wraps a verse with tap/long-press actions and text selection
class VerseWidget extends ConsumerStatefulWidget {
  final String verseId;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String bibleId;
  final double fontSize;
  
  const VerseWidget({
    super.key,
    required this.verseId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.bibleId,
    this.fontSize = 16,
  });

  @override
  ConsumerState<VerseWidget> createState() => _VerseWidgetState();
}

class _VerseWidgetState extends ConsumerState<VerseWidget> {
  String? _highlightColor;
  int? _highlightStart;
  int? _highlightEnd;
  bool _isBookmarked = false;
  String? _note;
  String? _selectedText;
  int? _selectionStart;
  int? _selectionEnd;
  
  @override
  void initState() {
    super.initState();
    _loadState();
  }
  
  Future<void> _loadState() async {
    try {
      await VerseStorageService.initialize();

      final highlights = VerseStorageService.getHighlights();
      final highlightVerse = highlights[widget.verseId];
      final highlight = highlightVerse?.highlightColor;

      final bookmarked = VerseStorageService.isBookmarked(widget.verseId);
      final note = VerseStorageService.getNote(widget.verseId);

      if (mounted) {
        setState(() {
          _highlightColor = highlight;
          _highlightStart = highlightVerse?.highlightStart;
          _highlightEnd = highlightVerse?.highlightEnd;
          _isBookmarked = bookmarked;
          _note = note;
        });
      }
    } catch (e) {
      debugPrint('Failed to load verse storage data: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showActionsMenu,
      onTap: _showQuickActions,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          // Keep container neutral so partial highlights only affect selected text span.
          color: null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verse number (tappable)
            GestureDetector(
              onTap: _showQuickActions,
              child: Container(
                width: 34,
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Text(
                          '${widget.verse}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (_isBookmarked)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Icon(
                              Icons.bookmark,
                              size: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (_highlightColor != null)
                      Icon(
                        (_highlightStart != null && _highlightEnd != null &&
                                !(_highlightStart == 0 && _highlightEnd == widget.text.length))
                            ? Icons.tune
                            : Icons.flash_on,
                        size: 10,
                        color: Color(HighlightColors.getColorValue(_highlightColor!)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Verse text with selection support
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      children: _buildHighlightedSpans(context),
                    ),
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      height: 1.6,
                    ),
                    onSelectionChanged: (selection, cause) {
                      if (selection.isCollapsed) {
                        if (mounted) {
                          setState(() {
                            _selectedText = null;
                            _selectionStart = null;
                            _selectionEnd = null;
                          });
                        }
                        return;
                      }

                      final start = selection.start;
                      final end = selection.end;
                      if (start >= 0 && end > start && end <= widget.text.length) {
                        final selectedText = widget.text.substring(start, end);
                        if (mounted) {
                          setState(() {
                            _selectedText = selectedText;
                            _selectionStart = start;
                            _selectionEnd = end;
                          });
                        }
                      }
                    },
                  ),
                  
                  // Note indicator
                  if (_note != null && _note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.note, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _note!,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Footnote button
                  Consumer(
                    builder: (context, ref, child) {
                      final footnoteService = ref.watch(footnoteServiceProvider);
                      final footnotes = footnoteService.getFootnotes(widget.bookId, widget.chapter, widget.verse);
                      final crossRefs = footnoteService.getCrossReferences(widget.bookId, widget.chapter, widget.verse);
                      
                      if (footnotes.isEmpty && crossRefs.isEmpty) return const SizedBox.shrink();
                      
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () => _showFootnoteBottomSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Study Notes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (footnotes.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${footnotes.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<InlineSpan> _buildHighlightedSpans(BuildContext context) {
    final hasRange = _highlightColor != null &&
        _highlightStart != null &&
        _highlightEnd != null &&
        _highlightStart! >= 0 &&
        _highlightEnd! > _highlightStart! &&
        _highlightEnd! <= widget.text.length;

    // If no valid range, do NOT whole-verse highlight.
    // User requested manual partial highlighting only.
    if (!hasRange) {
      return [TextSpan(text: widget.text)];
    }

    final color = Color(HighlightColors.getColorValue(_highlightColor!)).withOpacity(0.35);
    final start = _highlightStart!;
    final end = _highlightEnd!;

    return [
      if (start > 0) TextSpan(text: widget.text.substring(0, start)),
      TextSpan(
        text: widget.text.substring(start, end),
        style: TextStyle(backgroundColor: color),
      ),
      if (end < widget.text.length) TextSpan(text: widget.text.substring(end)),
    ];
  }

  void _showQuickActions() {
    HapticFeedback.lightImpact();
    if (_selectedText != null && _selectionStart != null && _selectionEnd != null) {
      _showHighlightOptionsForSelection(_selectedText!);
      return;
    }
    _showActionsSheet();
  }
  
  void _showActionsMenu() {
    HapticFeedback.mediumImpact();
    _showActionsSheet();
  }
  
  void _showFootnoteBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FootnoteBottomSheet(
        bookId: widget.bookId,
        chapter: widget.chapter,
        verse: widget.verse,
        verseText: widget.text,
        verseId: widget.verseId,
      ),
    );
  }
  
  void _showActionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _VerseActionsSheet(
        verseId: widget.verseId,
        bookId: widget.bookId,
        bookName: widget.bookName,
        chapter: widget.chapter,
        verse: widget.verse,
        text: widget.text,
        bibleId: widget.bibleId,
        isBookmarked: _isBookmarked,
        currentHighlight: _highlightColor,
        currentNote: _note,
        hasSelectedText: _selectedText != null && _selectionStart != null && _selectionEnd != null,
        onPrecisionHighlightRequested: () {
          Navigator.pop(context);
          if (_selectedText != null && _selectionStart != null && _selectionEnd != null) {
            _showHighlightOptionsForSelection(_selectedText!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select text in the verse first, then tap Precision Highlight.')),
            );
          }
        },
        onStateChanged: ({
          bool? bookmarked,
          String? highlight,
          String? note,
          int? highlightStart,
          int? highlightEnd,
          String? highlightText,
        }) {
          setState(() {
            if (bookmarked != null) _isBookmarked = bookmarked;
            if (highlight != null) _highlightColor = highlight.isEmpty ? null : highlight;
            if (note != null) _note = note.isEmpty ? null : note;
            if (highlightStart != null || highlight == '') _highlightStart = highlightStart;
            if (highlightEnd != null || highlight == '') _highlightEnd = highlightEnd;

          });
        },
      ),
    );
  }
  
  void _showHighlightOptionsForSelection(String selectedText) {
    // Show highlight color picker for selected text
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Highlight: "$selectedText"',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: HighlightColors.all.map((color) {
                return GestureDetector(
                  onTap: () async {
                    await VerseStorageService.setHighlight(
                      SavedVerse(
                        id: widget.verseId,
                        bookId: widget.bookId,
                        bookName: widget.bookName,
                        chapter: widget.chapter,
                        verse: widget.verse,
                        text: widget.text,
                        savedAt: DateTime.now(),
                        bibleId: widget.bibleId,
                      ),
                      color,
                      start: _selectionStart,
                      end: _selectionEnd,
                      selectedText: _selectedText,
                    );
                    if (!context.mounted) return;
                    setState(() {
                      _highlightColor = color;
                      _highlightStart = _selectionStart;
                      _highlightEnd = _selectionEnd;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(HighlightColors.getColorValue(color)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Actions sheet for verse operations
class _VerseActionsSheet extends StatelessWidget {
  final String verseId;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String bibleId;
  final bool isBookmarked;
  final String? currentHighlight;
  final String? currentNote;
  final bool hasSelectedText;
  final VoidCallback onPrecisionHighlightRequested;
  final Function({
    bool? bookmarked,
    String? highlight,
    String? note,
    int? highlightStart,
    int? highlightEnd,
    String? highlightText,
  }) onStateChanged;
  
  const _VerseActionsSheet({
    required this.verseId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.bibleId,
    required this.isBookmarked,
    required this.currentHighlight,
    required this.currentNote,
    required this.hasSelectedText,
    required this.onPrecisionHighlightRequested,
    required this.onStateChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reference
          Row(
            children: [
              Text(
                '$bookName $chapter:$verse',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Verse preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              text.isEmpty ? '[Verse text unavailable]' : text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Explicit highlight modes
          Text('Quick Highlight (whole verse):', style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorButton(context, null, 'None'),
              ...HighlightColors.all.map((color) => 
                _buildColorButton(context, color, null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Precision Highlight (selected text only):',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.text_fields),
              label: Text(hasSelectedText
                  ? 'Precision Highlight Selected Text'
                  : 'Select Text First for Precision Highlight'),
              onPressed: onPrecisionHighlightRequested,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: select text in the verse body, then use this button to color only that selected portion.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  label: isBookmarked ? 'Bookmarked' : 'Bookmark',
                  isActive: isBookmarked,
                  onPressed: () async {
                    final savedVerse = SavedVerse(
                      id: verseId,
                      bookId: bookId,
                      bookName: bookName,
                      chapter: chapter,
                      verse: verse,
                      text: text,
                      savedAt: DateTime.now(),
                      bibleId: bibleId,
                    );
                    
                    if (isBookmarked) {
                      await VerseStorageService.removeBookmark(verseId);
                      onStateChanged(bookmarked: false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bookmark removed')),
                        );
                      }
                    } else {
                      await VerseStorageService.addBookmark(savedVerse);
                      onStateChanged(bookmarked: true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bookmarked!')),
                        );
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: currentNote != null ? Icons.note : Icons.note_add_outlined,
                  label: currentNote != null ? 'Edit Note' : 'Add Note',
                  isActive: currentNote != null,
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await _showNoteDialog(context, currentNote);
                    if (result != null) {
                      final savedVerse = SavedVerse(
                        id: verseId,
                        bookId: bookId,
                        bookName: bookName,
                        chapter: chapter,
                        verse: verse,
                        text: text,
                        savedAt: DateTime.now(),
                        bibleId: bibleId,
                      );
                      
                      if (result.isEmpty) {
                        await VerseStorageService.removeNote(verseId);
                        onStateChanged(note: '');
                      } else {
                        await VerseStorageService.saveNote(savedVerse, result);
                        onStateChanged(note: result);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Copy button
          SizedBox(
            width: double.infinity,
            child: _ActionButton(
              icon: Icons.copy,
              label: 'Copy Verse',
              onPressed: () {
                final copyText = '$bookName $chapter:$verse\n\n$text';
                Clipboard.setData(ClipboardData(text: copyText));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verse copied to clipboard!')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          
          // Compare translations button
          SizedBox(
            width: double.infinity,
            child: _ActionButton(
              icon: Icons.compare_arrows,
              label: 'Compare Translations',
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerseComparisonPage(
                      initialBookId: bookId,
                      initialBookName: bookName,
                      initialChapter: chapter,
                      initialVerse: verse,
                      initialVerseText: text,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorButton(BuildContext context, String? color, String? label) {
    final isSelected = currentHighlight == color;
    
    return GestureDetector(
      onTap: () async {
        final savedVerse = SavedVerse(
          id: verseId,
          bookId: bookId,
          bookName: bookName,
          chapter: chapter,
          verse: verse,
          text: text,
          savedAt: DateTime.now(),
          bibleId: bibleId,
        );
        
        if (color == null) {
          await VerseStorageService.removeHighlight(verseId);
          onStateChanged(highlight: '', highlightStart: null, highlightEnd: null, highlightText: null);
          if (context.mounted) Navigator.pop(context);
          return;
        }

        // Apply immediately as full-verse highlight when chosen from actions sheet.
        await VerseStorageService.setHighlight(
          savedVerse,
          color,
          start: 0,
          end: text.length,
          selectedText: text,
        );
        onStateChanged(
          highlight: color,
          highlightStart: 0,
          highlightEnd: text.length,
          highlightText: text,
        );
        if (context.mounted) Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color != null
              ? Color(HighlightColors.getColorValue(color))
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: isSelected 
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary, 
                  width: 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: color == null
            ? Icon(Icons.clear, size: 20, color: Theme.of(context).colorScheme.outline)
            : null,
      ),
    );
  }
  
  Future<String?> _showNoteDialog(BuildContext context, String? currentNote) async {
    final controller = TextEditingController(text: currentNote ?? '');
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentNote != null ? 'Edit Note' : 'Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Write your study note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          if (currentNote != null)
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive 
            ? Theme.of(context).colorScheme.primary 
            : null,
        side: isActive 
            ? BorderSide(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
      onPressed: onPressed,
    );
  }
}
