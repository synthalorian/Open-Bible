import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import 'chapter_reader_page.dart';

/// Book chapters page - shows grid of chapters for a book
class BookChaptersPage extends StatelessWidget {
  final String bookId;

  const BookChaptersPage({
    super.key,
    required this.bookId,
  });

  String get _bookName {
    // Convert bookId back to proper name
    final allBooks = BibleStructure.allBooks;
    for (final book in allBooks) {
      if (book.toLowerCase() == bookId.toLowerCase()) {
        return book;
      }
    }
    return bookId;
  }

  int get _chapterCount => BibleStructure.getChapterCount(_bookName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bookName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Book info',
            onPressed: () => _showBookInfo(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book overview card
            _buildOverviewCard(context),
            const SizedBox(height: 24),
            // Chapters header
            Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Chapters grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _chapterCount,
                itemBuilder: (context, index) {
                  final chapterNum = index + 1;
                  return _ChapterGridItem(
                    chapterNumber: chapterNum,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterReaderPage(
                          bookId: bookId,
                          chapter: chapterNum,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final isOT = BibleStructure.isOldTestament(_bookName);
    final testament = isOT ? 'Old Testament' : 'New Testament';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _bookName.substring(0, _bookName.length > 3 ? 3 : _bookName.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bookName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$testament • $_chapterCount chapters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              tooltip: 'Listen to audiobook',
              onPressed: () => _playAudio(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _bookName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                BibleStructure.isOldTestament(_bookName) 
                    ? 'Old Testament' 
                    : 'New Testament',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _InfoRow(
                icon: Icons.format_list_numbered,
                label: 'Chapters',
                value: '$_chapterCount',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.category_outlined,
                label: 'Category',
                value: _getBookCategory(),
              ),
              const SizedBox(height: 24),
              Text(
                _getBookDescription(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBookCategory() {
    // Simplified categorization
    if (BibleStructure.isOldTestament(_bookName)) {
      if (['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy']
          .contains(_bookName)) {
        return 'Pentateuch (Law)';
      }
      if (['Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel', 
           '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 
           'Ezra', 'Nehemiah', 'Esther'].contains(_bookName)) {
        return 'Historical Books';
      }
      if (['Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon']
          .contains(_bookName)) {
        return 'Wisdom Literature';
      }
      return 'Prophetic Books';
    } else {
      if (['Matthew', 'Mark', 'Luke', 'John'].contains(_bookName)) {
        return 'Gospels';
      }
      if (_bookName == 'Acts') return 'History';
      if (['Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 
           'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians',
           '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 
           'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
           '1 John', '2 John', '3 John', 'Jude'].contains(_bookName)) {
        return 'Epistles';
      }
      return 'Apocalyptic';
    }
  }

  String _getBookDescription() {
    // Return a brief description based on the book
    // In a real app, this would come from a data file
    return 'The book of $_bookName is part of the ${BibleStructure.isOldTestament(_bookName) ? "Old" : "New"} Testament. '
        'It contains $_chapterCount chapters of sacred scripture that reveal God\'s word to humanity.';
  }

  void _playAudio(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio is available in the chapter reader.')),
    );
  }
}

class _ChapterGridItem extends StatelessWidget {
  final int chapterNumber;
  final VoidCallback onTap;

  const _ChapterGridItem({
    required this.chapterNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            '$chapterNumber',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
