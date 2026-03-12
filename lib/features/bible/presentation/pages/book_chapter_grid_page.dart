import 'package:flutter/material.dart';
import '../../../../core/models/parsed_bible.dart';
import 'inline_chapter_reader_page.dart';

/// Grid of chapter numbers for a book — tapping opens the inline reader.
class BookChapterGridPage extends StatelessWidget {
  final ParsedBibleBook book;
  const BookChapterGridPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.name)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: book.chapters.length,
        itemBuilder: (context, index) {
          final chapter = book.chapters[index];
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
      ),
    );
  }

  void _openChapter(BuildContext context, ParsedBibleChapter chapter, int chapterIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InlineChapterReaderPage(
          book: book,
          initialChapterIndex: chapterIndex,
        ),
      ),
    );
  }
}
