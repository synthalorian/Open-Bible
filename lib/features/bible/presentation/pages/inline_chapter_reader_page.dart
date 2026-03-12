import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/parsed_bible.dart';
import '../../../../core/services/footnote_service.dart';
import '../../../../core/services/verse_storage_service.dart';
import '../../../../core/services/current_bible.dart';
import '../../../../core/services/reading_history_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../concordance/presentation/pages/concordance_page.dart';
import '../../../audio/presentation/audio_bible_widget.dart';
import '../widgets/verse_display_widget.dart';

/// Chapter reader that receives a pre-parsed [ParsedBibleBook] with inline
/// verse data.  Supports swipe navigation between chapters.
class InlineChapterReaderPage extends ConsumerStatefulWidget {
  final ParsedBibleBook book;
  final int initialChapterIndex;

  const InlineChapterReaderPage({
    super.key,
    required this.book,
    required this.initialChapterIndex,
  });

  @override
  ConsumerState<InlineChapterReaderPage> createState() => _InlineChapterReaderPageState();
}

class _InlineChapterReaderPageState extends ConsumerState<InlineChapterReaderPage> {
  late PageController _pageController;
  late int _currentChapterIndex;

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _pageController = PageController(initialPage: widget.initialChapterIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentChapterIndex = index;
    });

    final chapter = widget.book.chapters[index];
    ReadingHistoryService.addEntry(HistoryEntry(
      bookId: widget.book.id,
      bookName: widget.book.name,
      chapter: chapter.chapter,
      bibleId: CurrentBible.id,
      readAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.book.chapters[_currentChapterIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book.name} ${chapter.chapter}'),
        actions: [
          CompactAudioButton(
            verseText: chapter.verses.map((v) => '${v.verse}. ${v.text}').join('\n'),
            verseReference: '${widget.book.name} ${chapter.chapter}',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'bookmark') {
                final chapterRef = '${widget.book.name} ${chapter.chapter}:1';
                final verse = SavedVerse(
                  id: chapterRef,
                  bookId: widget.book.name.replaceAll(' ', '').toUpperCase(),
                  bookName: widget.book.name,
                  chapter: chapter.chapter,
                  verse: 1,
                  text: 'Chapter bookmark',
                  savedAt: DateTime.now(),
                  bibleId: CurrentBible.id,
                );
                await VerseStorageService.addBookmark(verse);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bookmarked ${widget.book.name} ${chapter.chapter}')),
                );
              } else if (value == 'concordance') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConcordancePage()),
                );
              }
              // Removed 'translations' option - now available via long-press on verses
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bookmark',
                child: ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Bookmark Chapter'),
                ),
              ),
              const PopupMenuItem(
                value: 'concordance',
                child: ListTile(
                  leading: Icon(Icons.menu_book),
                  title: Text('Strong\'s Concordance'),
                ),
              ),
              // Translations removed from here - use long-press on verse instead
            ],
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.book.chapters.length,
        itemBuilder: (context, index) {
          final ch = widget.book.chapters[index];
          return _buildChapterView(ch);
        },
      ),
    );
  }

  Widget _buildChapterView(ParsedBibleChapter chapter) {
    return Column(
      children: [
        AudioBibleWidget(
          verseText: chapter.verses.map((v) => '${v.verse}. ${v.text}').join('\n'),
          verseReference: '${widget.book.name} ${chapter.chapter}',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapter.verses.length,
            itemBuilder: (context, index) {
              final verse = chapter.verses[index];
              final bookId = widget.book.id.isNotEmpty
                  ? widget.book.id
                  : (AppConstants.bookAbbreviations[widget.book.name.toLowerCase()] ?? widget.book.name.replaceAll(' ', '').toUpperCase());
              final footnotes = FootnoteService().getFootnotes(
                bookId,
                chapter.chapter,
                verse.verse,
              );
              return VerseDisplayWidget(
                verseId: '${widget.book.name} ${chapter.chapter}:${verse.verse}',
                verseNumber: verse.verse,
                verseText: verse.text,
                bookId: bookId,
                bookName: widget.book.name,
                chapter: chapter.chapter,
                bibleId: CurrentBible.id,
                footnotes: footnotes.map((f) => '${f.id}. ${f.text}').toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
