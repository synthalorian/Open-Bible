import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart' show BibleStructure;
import '../../../../core/services/bible_commentary.dart';
import '../../../bible/presentation/pages/chapter_reader_page.dart';

/// Commentary page - study notes & commentary
class CommentaryPage extends StatefulWidget {
  final String? bookId;
  final int? chapter;
  
  const CommentaryPage({
    super.key,
    this.bookId,
    this.chapter,
  });

  @override
  State<CommentaryPage> createState() => _CommentaryPageState();
}

class _CommentaryPageState extends State<CommentaryPage> {
  String _selectedBook = 'genesis';
  int _selectedChapter = 1;
  
  final List<String> _books = [
    'genesis', 'exodus', 'psalms', 'isaiah', 'matthew', 'john', 'romans', 'revelation'
  ];
  
  @override
  void initState() {
    super.initState();
    if (widget.bookId != null) {
      _selectedBook = widget.bookId!;
    }
    if (widget.chapter != null) {
      _selectedChapter = widget.chapter!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentary = BibleCommentary.getChapterCommentary(_selectedBook, _selectedChapter);
    final hasCommentary = commentary != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Commentary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Book and chapter selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Book',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    initialValue: _selectedBook,
                    items: _books.map((book) => DropdownMenuItem(
                      value: book,
                      child: Text(_capitalize(book)),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedBook = value;
                          _selectedChapter = 1;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Chapter',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    initialValue: _selectedChapter,
                    items: List.generate(BibleStructure.getChapterCount(_capitalize(_selectedBook)).clamp(1, 150), (i) => i + 1)
                        .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedChapter = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Commentary content
          Expanded(
            child: hasCommentary
                ? _buildCommentaryContent(commentary)
                : _buildNoCommentary(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryContent(String commentary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_capitalize(_selectedBook)} $_selectedChapter',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Study Notes',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Commentary text
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: SelectableText(
              commentary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Read Chapter'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterReaderPage(
                          bookId: _selectedBook,
                          chapter: _selectedChapter,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Available commentaries
          Text(
            'Available Commentaries',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _books.map((book) {
              final hasNotes = BibleCommentary.hasCommentary(book, 1);
              return ActionChip(
                avatar: hasNotes 
                    ? const Icon(Icons.check, size: 16)
                    : const Icon(Icons.close, size: 16),
                label: Text(_capitalize(book)),
                onPressed: () {
                  setState(() {
                    _selectedBook = book;
                    _selectedChapter = 1;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCommentary() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No commentary available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different book or chapter',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('View Available Commentaries'),
            onPressed: () => _showAvailableCommentaries(),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Commentary'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This commentary provides study notes and explanations for Bible chapters. '
              'It draws from classic commentaries and modern scholarship to help you '
              'understand Scripture more deeply.',
            ),
            SizedBox(height: 16),
            Text(
              'Currently Available:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Genesis (chapters 1-4, 12, 22)'),
            Text('• Exodus (chapters 1, 3, 12, 20)'),
            Text('• Psalms (1, 23, 51, 91, 119)'),
            Text('• Isaiah (chapter 53)'),
            Text('• Matthew (chapters 1, 5, 6, 28)'),
            Text('• John (chapters 1, 3, 10, 11, 20)'),
            Text('• Romans (chapters 1, 3, 8, 12)'),
            Text('• Revelation (chapters 1, 21, 22)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAvailableCommentaries() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Commentaries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Commentary is available for the following books:',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BibleCommentary.availableBooks.map((book) => 
                ActionChip(
                  label: Text(_capitalize(book)),
                  onPressed: () {
                    setState(() {
                      _selectedBook = book;
                      _selectedChapter = 1;
                    });
                    Navigator.pop(context);
                  },
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
