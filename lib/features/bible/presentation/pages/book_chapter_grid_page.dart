import 'package:flutter/material.dart';
import '../../../../core/models/parsed_bible.dart';
import 'inline_chapter_reader_page.dart';

/// Simple search result model for this page
class _ChapterSearchResult {
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String query;

  _ChapterSearchResult({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.query,
  });

  String get reference => '$bookName $chapter:$verse';
}

/// Grid of chapter numbers for a book — tapping opens the inline reader.
class BookChapterGridPage extends StatefulWidget {
  final ParsedBibleBook book;
  const BookChapterGridPage({super.key, required this.book});

  @override
  State<BookChapterGridPage> createState() => _BookChapterGridPageState();
}

class _BookChapterGridPageState extends State<BookChapterGridPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<_ChapterSearchResult> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      final results = <_ChapterSearchResult>[];
      final lowerQuery = query.toLowerCase();
      
      // Search within current book only
      for (final chapter in widget.book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(lowerQuery)) {
            results.add(_ChapterSearchResult(
              bookId: widget.book.id,
              bookName: widget.book.name,
              chapter: chapter.chapter,
              verse: verse.verse,
              text: verse.text,
              query: query,
            ));
          }
        }
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search ${widget.book.name}...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 18),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {}); // Update suffix icon visibility
                // Debounce search
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              onSubmitted: (value) {
                _performSearch(value);
              },
            )
          : Text(widget.book.name),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchResults = [];
                }
              });
            },
          ),
        ],
      ),
      body: _isSearching 
        ? _buildSearchResults() 
        : _buildChapterGrid(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results in ${widget.book.name}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(
            result.reference,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          subtitle: Text(
            result.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _openChapterFromSearch(result.chapter - 1),
        );
      },
    );
  }

  Widget _buildChapterGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.book.chapters.length,
      itemBuilder: (context, index) {
        final chapter = widget.book.chapters[index];
        return InkWell(
          onTap: () => _openChapter(context, chapter, index),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${chapter.chapter}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openChapter(BuildContext context, ParsedBibleChapter chapter, int chapterIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InlineChapterReaderPage(
          book: widget.book,
          initialChapterIndex: chapterIndex,
        ),
      ),
    );
  }

  void _openChapterFromSearch(int chapterIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InlineChapterReaderPage(
          book: widget.book,
          initialChapterIndex: chapterIndex,
        ),
      ),
    );
  }
}
