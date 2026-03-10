import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/verse_storage_service.dart';
import 'footnote_bottom_sheet.dart';

/// Verse display widget with footnotes support
class VerseDisplayWidget extends ConsumerStatefulWidget {
  final String verseId;
  final int verseNumber;
  final String verseText;
  final String bookId;
  final String? bookName;
  final int chapter;
  final String? bibleId;
  final List<String> footnotes;
  final bool showFootnotes;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const VerseDisplayWidget({
    super.key,
    required this.verseId,
    required this.verseNumber,
    required this.verseText,
    required this.bookId,
    this.bookName,
    required this.chapter,
    this.bibleId,
    this.footnotes = const [],
    this.showFootnotes = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  ConsumerState<VerseDisplayWidget> createState() => _VerseDisplayWidgetState();
}

class _VerseDisplayWidgetState extends ConsumerState<VerseDisplayWidget> {
  
  String? _selectedText;
  int? _selectionStart;
  int? _selectionEnd;

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(settingsProvider).fontSize.toDouble();
    final highlightColor = ref.watch(highlightsProvider)[widget.verseId];
    final preciseHighlight = VerseStorageService.getHighlight(widget.verseId);
    final isBookmarked = ref.watch(bookmarksProvider).contains(widget.verseId);
    final note = ref.watch(notesProvider)[widget.verseId];
    
    return InkWell(
      onTap: widget.onTap ?? _toggleFootnotes,
      onLongPress: widget.onLongPress ?? () => _showVerseOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: _isFullVerseHighlight(highlightColor, preciseHighlight)
            ? BoxDecoration(
                color: _parseColor(highlightColor!).withOpacity(0.2),
                border: Border(
                  left: BorderSide(
                    color: _parseColor(highlightColor),
                    width: 4,
                  ),
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse number
                Container(
                  width: 32,
                  child: Text(
                    '${widget.verseNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                // Verse text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelectableVerseText(
                        fontSize: fontSize,
                        highlightColor: highlightColor,
                        preciseHighlight: preciseHighlight,
                      ),
                      // Note indicator
                      if (note != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  note,
                                  style: TextStyle(
                                    fontSize: fontSize - 2,
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Bookmark indicator
                if (isBookmarked)
                  Icon(
                    Icons.bookmark,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            // Footnotes indicator
            if (widget.showFootnotes) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _toggleFootnotes,
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
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'View Footnotes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  bool _isFullVerseHighlight(String? color, SavedVerse? precise) {
    if (color == null) return false;
    if (precise == null) return true;

    final start = precise.highlightStart;
    final end = precise.highlightEnd;
    if (start == null || end == null) return true;

    return start <= 0 && end >= widget.verseText.length;
  }

  Widget _buildSelectableVerseText({
    required double fontSize,
    required String? highlightColor,
    required SavedVerse? preciseHighlight,
  }) {
    final color = highlightColor != null ? _parseColor(highlightColor).withOpacity(0.35) : null;
    final start = preciseHighlight?.highlightStart;
    final end = preciseHighlight?.highlightEnd;
    final canApplyRange = color != null && start != null && end != null && start >= 0 && end <= widget.verseText.length && start < end;

    TextSpan span;
    if (canApplyRange && !_isFullVerseHighlight(highlightColor, preciseHighlight)) {
      span = TextSpan(
        style: TextStyle(fontSize: fontSize, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
        children: [
          TextSpan(text: widget.verseText.substring(0, start)),
          TextSpan(
            text: widget.verseText.substring(start, end),
            style: TextStyle(backgroundColor: color),
          ),
          TextSpan(text: widget.verseText.substring(end)),
        ],
      );
    } else {
      span = TextSpan(
        text: widget.verseText,
        style: TextStyle(fontSize: fontSize, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
      );
    }

    return SelectableText.rich(
      span,
      onSelectionChanged: (selection, cause) {
        final s = selection.start;
        final e = selection.end;
        final valid = s >= 0 && e >= 0 && s < e && e <= widget.verseText.length;

        if (valid) {
          setState(() {
            _selectionStart = s;
            _selectionEnd = e;
            _selectedText = widget.verseText.substring(s, e);
          });
        } else {
          setState(() {
            _selectionStart = null;
            _selectionEnd = null;
            _selectedText = null;
          });
        }
      },
    );
  }

  void _toggleFootnotes() {
    if (!widget.showFootnotes) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FootnoteBottomSheet(
        bookId: widget.bookId,
        chapter: widget.chapter,
        verse: widget.verseNumber,
        verseText: widget.verseText,
        verseId: widget.verseId,
      ),
    );
  }
  
  void _showVerseOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => VerseOptionsSheet(
        hostContext: context,
        verseId: widget.verseId,
        verseText: widget.verseText,
        bookId: widget.bookId,
        bookName: widget.bookName,
        chapter: widget.chapter,
        verseNumber: widget.verseNumber,
        bibleId: widget.bibleId,
        selectedText: _selectedText,
        selectionStart: _selectionStart,
        selectionEnd: _selectionEnd,
      ),
    );
  }
  
  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}

/// Verse options bottom sheet
class VerseOptionsSheet extends ConsumerWidget {
  final BuildContext hostContext;
  final String verseId;
  final String verseText;
  final String bookId;
  final String? bookName;
  final int chapter;
  final int verseNumber;
  final String? bibleId;
  final String? selectedText;
  final int? selectionStart;
  final int? selectionEnd;
  
  const VerseOptionsSheet({
    super.key,
    required this.hostContext,
    required this.verseId,
    required this.verseText,
    required this.bookId,
    this.bookName,
    required this.chapter,
    required this.verseNumber,
    this.bibleId,
    this.selectedText,
    this.selectionStart,
    this.selectionEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarksProvider).contains(verseId);
    final currentHighlightColor = ref.watch(highlightsProvider)[verseId];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${bookName ?? bookId} $chapter:$verseNumber',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (selectedText != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Selected: "$selectedText"',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.colorize, color: Colors.blue),
              title: const Text('Precision Highlight Selection'),
              onTap: () {
                final container = ProviderScope.containerOf(hostContext, listen: false);
                Navigator.pop(context);
                _showHighlightPicker(hostContext, container, currentHighlightColor, isPrecision: true);
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: isBookmarked ? Theme.of(context).colorScheme.primary : null,
            ),
            title: Text(isBookmarked ? 'Remove Bookmark' : 'Add Bookmark'),
            onTap: () async {
              final savedVerse = SavedVerse(
                id: verseId,
                bookId: bookId,
                bookName: bookName ?? bookId,
                chapter: chapter,
                verse: verseNumber,
                text: verseText,
                savedAt: DateTime.now(),
                bibleId: bibleId ?? 'kjv',
              );

              try {
                if (isBookmarked) {
                  await ref.read(bookmarksProvider.notifier).removeBookmark(verseId);
                  await VerseStorageService.removeBookmark(verseId);
                } else {
                  await ref.read(bookmarksProvider.notifier).addBookmark(verseId);
                  await VerseStorageService.addBookmark(savedVerse);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isBookmarked ? 'Bookmark removed' : 'Bookmark saved')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bookmark failed: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_paint),
            title: const Text('Highlight Full Verse'),
            trailing: currentHighlightColor != null
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _parseColor(currentHighlightColor),
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
            onTap: () {
              final container = ProviderScope.containerOf(hostContext, listen: false);
              Navigator.pop(context);
              _showHighlightPicker(hostContext, container, currentHighlightColor, isPrecision: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('Add Note'),
            onTap: () {
              final container = ProviderScope.containerOf(hostContext, listen: false);
              Navigator.pop(context);
              _showNoteDialog(hostContext, container);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () async {
              final payload = '${bookName ?? bookId} $chapter:$verseNumber\n\n$verseText';
              Navigator.pop(context);
              try {
                await Share.share(payload, subject: '${bookName ?? bookId} $chapter:$verseNumber');
              } on MissingPluginException {
                await Clipboard.setData(ClipboardData(text: payload));
                if (hostContext.mounted) {
                  ScaffoldMessenger.of(hostContext).showSnackBar(
                    const SnackBar(content: Text('Share is unavailable on this build. Verse copied to clipboard.')),
                  );
                }
              } catch (e) {
                if (hostContext.mounted) {
                  ScaffoldMessenger.of(hostContext).showSnackBar(
                    SnackBar(content: Text('Could not share: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () async {
              final payload = '${bookName ?? bookId} $chapter:$verseNumber\n\n$verseText';
              await Clipboard.setData(ClipboardData(text: payload));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verse copied to clipboard')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  void _showHighlightPicker(BuildContext context, ProviderContainer container, String? currentHighlightColor, {required bool isPrecision}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPrecision ? 'Select Precision Highlight Color' : 'Select Highlight Color',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPrecision ? 'Applying to selection only' : 'Applying to full verse',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                {'name': 'yellow', 'color': Colors.yellow},
                {'name': 'green', 'color': Colors.green},
                {'name': 'blue', 'color': Colors.blue},
                {'name': 'red', 'color': Colors.red},
                {'name': 'purple', 'color': Colors.purple},
                {'name': 'orange', 'color': Colors.orange},
                {'name': 'pink', 'color': Colors.pink},
                {'name': 'cyan', 'color': Colors.cyan},
              ].map((colorData) {
                final colorName = colorData['name'] as String;
                final color = colorData['color'] as Color;
                final isCurrent = currentHighlightColor == colorName;
                
                return GestureDetector(
                  onTap: () async {
                    try {
                      await container.read(highlightsProvider.notifier).addHighlight(
                        verseId,
                        colorName,
                      );
                      
                      await VerseStorageService.setHighlight(
                        SavedVerse(
                          id: verseId,
                          bookId: bookId,
                          bookName: bookName ?? bookId,
                          chapter: chapter,
                          verse: verseNumber,
                          text: verseText,
                          savedAt: DateTime.now(),
                          bibleId: bibleId ?? 'kjv',
                        ),
                        colorName,
                        start: isPrecision ? selectionStart : 0,
                        end: isPrecision ? selectionEnd : verseText.length,
                        selectedText: isPrecision ? selectedText : null,
                      );
                      
                      if (context.mounted) {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Verse highlighted in ${colorName[0].toUpperCase()}${colorName.substring(1)}')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Highlight failed: $e')),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? Colors.black : Colors.grey,
                        width: isCurrent ? 3 : 1,
                      ),
                    ),
                    child: isCurrent ? const Icon(Icons.check, color: Colors.black) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (currentHighlightColor != null)
              TextButton.icon(
                onPressed: () async {
                  await container.read(highlightsProvider.notifier).removeHighlight(verseId);
                  await VerseStorageService.removeHighlight(verseId);
                  if (context.mounted) {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Highlight removed')),
                    );
                  }
                },
                icon: const Icon(Icons.clear),
                label: const Text('Remove Highlight'),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showNoteDialog(BuildContext context, ProviderContainer container) {
    final controller = TextEditingController(
      text: container.read(notesProvider)[verseId] ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (controller.text.isNotEmpty) {
                  await container.read(notesProvider.notifier).addNote(verseId, controller.text);
                  await VerseStorageService.saveNote(
                    SavedVerse(
                      id: verseId,
                      bookId: bookId,
                      bookName: bookName ?? bookId,
                      chapter: chapter,
                      verse: verseNumber,
                      text: verseText,
                      note: controller.text,
                      savedAt: DateTime.now(),
                      bibleId: bibleId ?? 'kjv',
                    ),
                    controller.text,
                  );
                } else {
                  await container.read(notesProvider.notifier).removeNote(verseId);
                  await VerseStorageService.removeNote(verseId);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note saved')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Note failed: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
