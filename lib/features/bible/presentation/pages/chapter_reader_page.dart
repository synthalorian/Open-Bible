import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/direct_bible_loader.dart';
import '../../../../core/services/continue_reading_service.dart';
import '../../../../core/services/current_bible.dart';
import '../../../../core/services/reading_history_service.dart';
import '../../../../core/services/verse_storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../commentary/presentation/pages/commentary_page.dart';
import '../../../maps/presentation/pages/bible_maps_page.dart';
import '../widgets/verse_widget.dart';

/// Chapter reader page - main reading view with swipe navigation
class ChapterReaderPage extends ConsumerStatefulWidget {
  final String bookId;
  final int chapter;

  const ChapterReaderPage({
    super.key,
    required this.bookId,
    required this.chapter,
  });

  @override
  ConsumerState<ChapterReaderPage> createState() => _ChapterReaderPageState();
}

class _ChapterReaderPageState extends ConsumerState<ChapterReaderPage> {
  late PageController _pageController;
  bool _showControls = true;
  bool _isPlayingAudio = false;
  int _currentChapter = 1;
  
  // Cache for chapter content
  final Map<String, String> _chapterCache = {};
  final Set<String> _loadingChapters = {};
  
  String get _bookName {
    final allBooks = BibleStructure.allBooks;
    for (final book in allBooks) {
      if (book.toLowerCase() == widget.bookId.toLowerCase()) {
        return book;
      }
    }
    return widget.bookId;
  }
  
  /// Parse verses from content string and display as interactive widgets
  Widget _buildVersesContent(String content, double fontSize, int chapter) {
    // Parse verses from format "1 In the beginning..."
    final verses = <Map<String, dynamic>>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      // Match verse number at start: "1 ", "2 ", etc.
      final match = RegExp(r'^(\d+)\s+(.+)$').firstMatch(line.trim());
      if (match != null) {
        verses.add({
          'verse': int.parse(match.group(1)!),
          'text': match.group(2)!,
        });
      }
    }
    
    if (verses.isEmpty) {
      // Fallback to plain text if parsing fails
      return SelectableText(
        content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: fontSize,
          height: 1.9,
        ),
      );
    }
    
    // Display as list of interactive verses
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: verses.map((v) => VerseWidget(
        verseId: '$_currentBibleId:${widget.bookId}:$chapter:${v['verse']}',
        bookId: widget.bookId,
        bookName: _bookName,
        chapter: chapter,
        verse: v['verse'] as int,
        text: v['text'] as String,
        bibleId: _currentBibleId,
        fontSize: fontSize,
      )).toList(),
    );
  }

  int get _totalChapters => BibleStructure.getChapterCount(_bookName);

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _pageController = PageController(initialPage: widget.chapter - 1);
    
    // Initialize _currentBibleId from provider
    final bibleData = ref.read(bibleDataProvider);
    final actualBibleId = bibleData.selectedTranslation?.id ?? 'kjv';
    _currentBibleId = PopularTranslations.getOfflineId(actualBibleId);
    debugPrint('INIT: Bible ID set to $_currentBibleId');
    
    // Listen for Bible changes
    ref.listenManual(bibleDataProvider, (previous, next) {
      final prevId = previous?.selectedTranslation?.id;
      final nextId = next.selectedTranslation?.id;
      
      if (prevId != nextId) {
        final prevOffline = PopularTranslations.getOfflineId(prevId ?? 'kjv');
        final nextOffline = PopularTranslations.getOfflineId(nextId ?? 'kjv');
        
        debugPrint('LISTENER: Bible changed from $prevOffline to $nextOffline');
        
        if (prevOffline != nextOffline) {
          setState(() {
            _chapterCache.clear();
            _currentBibleId = nextOffline;
          });
          // Reload current chapter
          _loadChapterContent(_currentChapter);
          // Reload adjacent
          if (_currentChapter > 1) _loadChapterContent(_currentChapter - 1);
          if (_currentChapter < _totalChapters) _loadChapterContent(_currentChapter + 1);
        }
      }
    });
    
    // Check initial audio state
    _checkAudioState();
    
    // Periodic audio state check (in case audio was started/stopped elsewhere)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _checkAudioState();
      }
    });
    
    // Load initial chapter
    _loadChapterContent(widget.chapter);
    
    _saveReadingPosition();
    _recordStreak();
    
    // Hide controls after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Track current Bible ID for cache invalidation
  String _currentBibleId = 'kjv';

  String _getCacheKey(String bibleId, int chapter) => '$bibleId.${widget.bookId}.$chapter';
  
  Future<void> _loadChapterContent(int chapter) async {
    // Get current Bible ID from GLOBAL STATE (reliable!)
    final bibleId = CurrentBible.id;
    
    // Use widget.bookId (e.g., "genesis") NOT _bookAbbr (e.g., "GEN")
    // The JSON files use full book names like "genesis", not abbreviations
    final bookId = widget.bookId.toLowerCase();
    
    final cacheKey = _getCacheKey(bibleId, chapter);
    
    debugPrint('LOADING: Bible=$bibleId, Book=$bookId, Chapter=$chapter');
    
    // Already cached or loading
    if (_chapterCache.containsKey(cacheKey) || _loadingChapters.contains(cacheKey)) {
      debugPrint('Already cached/loading: $cacheKey');
      return;
    }
    
    setState(() => _loadingChapters.add(cacheKey));

    try {
      // === Try Direct Bible Loader (always works offline) ===
      debugPrint('Trying DirectBibleLoader with: bibleId=$bibleId, bookId=$bookId, chapter=$chapter');

      var content = await DirectBibleLoader.getChapter(bibleId, bookId, chapter);
      if (content != null && content.isNotEmpty) {
        debugPrint('✓ Loaded from DirectBibleLoader');
        if (mounted) {
          setState(() {
            _chapterCache[cacheKey] = content!;
            _loadingChapters.remove(cacheKey);
          });
        }
        return;
      }

      // === Fallback to KJV if requested Bible not found ===
      debugPrint('Direct loader failed for $bibleId, trying KJV fallback...');
      content = await DirectBibleLoader.getChapter('kjv', bookId, chapter);
      if (content != null && content.isNotEmpty) {
        debugPrint('✓ Loaded from KJV fallback');
        if (mounted) {
          setState(() {
            _chapterCache[cacheKey] = '[KJV]\n\n$content';
            _loadingChapters.remove(cacheKey);
          });
        }
        return;
      }

      // === All failed ===
      if (mounted) {
        setState(() {
          _chapterCache[cacheKey] = 'Unable to load chapter. Bible: $bibleId';
          _loadingChapters.remove(cacheKey);
        });
      }

    } catch (e) {
      debugPrint('Critical error loading chapter: $e');
      if (mounted) {
        setState(() {
          _chapterCache[cacheKey] = 'Error: $e';
          _loadingChapters.remove(cacheKey);
        });
      }
    } finally {
      // Guarantee cleanup even if widget was unmounted during async gaps
      _loadingChapters.remove(cacheKey);
    }
  }

  void _saveReadingPosition() {
    debugPrint('SAVING READING POSITION: $_bookName $_currentChapter');
    
    ref.read(readingPositionProvider.notifier).updatePosition(
      ReadingPosition(
        bookId: widget.bookId,
        chapter: _currentChapter,
      ),
    );
    
    // Also save to ContinueReadingService for persistence
    final settings = ref.read(settingsProvider);
    final bibleId = settings.selectedBibleId;
    final bibleName = _getBibleName(bibleId);
    
    debugPrint('Saving to ContinueReadingService:');
    debugPrint('  bookId: ${widget.bookId}');
    debugPrint('  bookName: $_bookName');
    debugPrint('  chapter: $_currentChapter');
    debugPrint('  bibleId: $bibleId');
    debugPrint('  bibleName: $bibleName');
    
    ContinueReadingService.savePosition(
      bookId: widget.bookId,
      bookName: _bookName,
      chapter: _currentChapter,
      bibleId: bibleId,
      bibleName: bibleName,
    ).then((_) {
      debugPrint('✓ Position saved successfully');
    }).catchError((e) {
      debugPrint('✗ Error saving position: $e');
    });
    
    // Save to reading history
    ReadingHistoryService.addEntry(HistoryEntry(
      bookId: widget.bookId,
      bookName: _bookName,
      chapter: _currentChapter,
      bibleId: _currentBibleId,
      readAt: DateTime.now(),
    )).then((_) {
      debugPrint('✓ History entry saved');
    }).catchError((e) {
      debugPrint('✗ Error saving history: $e');
    });
  }
  
  String _getBibleName(String bibleId) {
    final bibles = DirectBibleLoader.availableBibles;
    for (final bible in bibles) {
      if (bible['id'] == bibleId) {
        return bible['name']!;
      }
    }
    return 'King James Version';
  }

  Future<void> _recordStreak() async {
    await VerseStorageService.initialize();
    final streakMap = VerseStorageService.getStreaks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final currentStreak = streakMap['currentStreak'] as int? ?? 0;
    final longestStreak = streakMap['longestStreak'] as int? ?? 0;
    final totalDaysRead = streakMap['totalDaysRead'] as int? ?? 0;
    final lastReadStr = streakMap['lastReadDate'] as String?;
    final lastReadDate = lastReadStr != null ? DateTime.tryParse(lastReadStr) : null;

    if (lastReadDate == null) {
      await VerseStorageService.saveStreaks({
        'currentStreak': 1,
        'longestStreak': longestStreak > 1 ? longestStreak : 1,
        'totalDaysRead': totalDaysRead + 1,
        'lastReadDate': today.toIso8601String(),
      });
      return;
    }

    final lastRead = DateTime(lastReadDate.year, lastReadDate.month, lastReadDate.day);
    final difference = today.difference(lastRead).inDays;

    if (difference >= 1) {
      final newStreak = difference == 1 ? currentStreak + 1 : 1;
      await VerseStorageService.saveStreaks({
        'currentStreak': newStreak,
        'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
        'totalDaysRead': totalDaysRead + 1,
        'lastReadDate': today.toIso8601String(),
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if Bible changed when returning to this page
    final bibleData = ref.read(bibleDataProvider);
    final currentBibleId = bibleData.selectedTranslation?.id ?? 'kjv';
    final offlineId = PopularTranslations.getOfflineId(currentBibleId);
    
    if (_currentBibleId != offlineId) {
      debugPrint('DID CHANGE DEPENDENCIES: Bible changed from $_currentBibleId to $offlineId');
      setState(() {
        _chapterCache.clear();
        _currentBibleId = offlineId;
      });
      // Reload current chapter with new Bible
      _loadChapterContent(_currentChapter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final bibleData = ref.watch(bibleDataProvider); // Watch for translation changes
    final currentBibleId = CurrentBible.id;
    
    debugPrint('BUILD: CurrentBible.id = $currentBibleId, watched = ${bibleData.selectedTranslation?.id}');
    
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Hide controls on any scroll activity
          if (_showControls && notification is ScrollStartNotification) {
            setState(() => _showControls = false);
          }
          return false;
        },
        child: Stack(
          children: [
            // Main content with PageView for swipe navigation
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                debugPrint('CHAPTER_READER: Outer GestureDetector onTap triggered');
                setState(() => _showControls = !_showControls);
                debugPrint('CHAPTER_READER: Controls toggled to: $_showControls');
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalChapters,
                onPageChanged: (index) {
                  final newChapter = index + 1;
                  setState(() {
                    _currentChapter = newChapter;
                  });
                  _loadChapterContent(newChapter);
                  _saveReadingPosition();

                  // Preload adjacent chapters
                  if (newChapter > 1) _loadChapterContent(newChapter - 1);
                  if (newChapter < _totalChapters) _loadChapterContent(newChapter + 1);
                },
                itemBuilder: (context, index) {
                  return _buildChapterContent(index + 1, settings);
                },
              ),
            ),

            // Top controls overlay
            if (_showControls) _buildTopControls(),

            // Bottom controls overlay
            if (_showControls) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterContent(int chapter, AppSettings settings) {
    // Get current Bible ID from GLOBAL STATE
    final bibleId = CurrentBible.id;
    final abbreviation = CurrentBible.abbreviation;

    final cacheKey = _getCacheKey(bibleId, chapter);
    final content = _chapterCache[cacheKey];
    final isLoading = _loadingChapters.contains(cacheKey);

    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('CHAPTER_READER: Inner GestureDetector onTap triggered');
          setState(() => _showControls = !_showControls);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      '$_bookName $chapter',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      abbreviation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Tip: Long-press verse number for Quick Highlight/Note/Bookmark. Or select text then tap verse for Precision Highlight.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (content != null)
                _buildVersesContent(content, settings.fontSize.toDouble(), chapter)
              else
                Center(
                  child: ElevatedButton(
                    onPressed: () => _loadChapterContent(chapter),
                    child: const Text('Load Chapter'),
                  ),
                ),
              const SizedBox(height: 48),
              Row(
                children: [
                  if (chapter > 1)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _goToChapter(chapter - 1),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                    ),
                  if (chapter > 1 && chapter < _totalChapters)
                    const SizedBox(width: 16),
                  if (chapter < _totalChapters)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _goToChapter(chapter + 1),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  '$_bookName $_currentChapter',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              IconButton(
                icon: Icon(_isPlayingAudio ? Icons.stop_circle : Icons.headphones_outlined),
                color: _isPlayingAudio ? Theme.of(context).colorScheme.primary : null,
                onPressed: () => _playAudio(),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsMenu(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final settings = ref.watch(settingsProvider);
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: 'Font Size',
                  icon: const Icon(Icons.text_fields),
                  onPressed: () => _showFontSizeSheet(),
                ),
                IconButton(
                  tooltip: 'Light/Dark',
                  icon: Icon(
                    settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () => _toggleTheme(),
                ),
                IconButton(
                  tooltip: _isPlayingAudio ? 'Stop Audio' : 'Play Audio',
                  icon: Icon(_isPlayingAudio ? Icons.stop_circle : Icons.headphones_outlined),
                  color: _isPlayingAudio ? Theme.of(context).colorScheme.primary : null,
                  onPressed: () => _playAudio(),
                ),
                IconButton(
                  tooltip: 'Bookmark Verse',
                  icon: const Icon(Icons.bookmark_outline),
                  onPressed: () => _bookmarkCurrentVerse(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToChapter(int chapter) {
    _pageController.animateToPage(
      chapter - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.comment_outlined),
              title: const Text('View Commentary'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CommentaryPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Compare Translations'),
              onTap: () {
                Navigator.pop(context);
                _showCompareTranslations();
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Related Maps'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BibleMapsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_edu_outlined),
              title: const Text('Historical Context'),
              onTap: () {
                Navigator.pop(context);
                _showHistoricalContext();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                _addNote();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCompareTranslations() async {
    // Default to verse 1 for comparison
    const currentVerse = 1;
    final reference = '$_bookName $_currentChapter:$currentVerse';
    
    // Show loading dialog first
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                reference,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _loadComparisonVerses(currentVerse),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final verses = snapshot.data ?? [];
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: verses.map((v) => _TranslationCard(
                      translation: v['translation']!,
                      text: v['text']!,
                    )).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, String>>> _loadComparisonVerses(int verseNumber) async {
    final results = <Map<String, String>>[];
    final translations = ['kjv', 'geneva', 'asv', 'web', 'leb'];
    
    for (final bibleId in translations) {
      try {
        final content = await DirectBibleLoader.getChapter(bibleId, widget.bookId, _currentChapter);
        if (content != null) {
          // Parse verse from content
          final lines = content.split('\n');
          String? verseText;
          for (final line in lines) {
            final match = RegExp(r'^(\d+)\s+(.+)$').firstMatch(line.trim());
            if (match != null && int.parse(match.group(1)!) == verseNumber) {
              verseText = match.group(2);
              break;
            }
          }
          results.add({
            'translation': bibleId.toUpperCase(),
            'text': verseText ?? 'Verse not found',
          });
        } else {
          results.add({
            'translation': bibleId.toUpperCase(),
            'text': 'Translation not available',
          });
        }
      } catch (e) {
        results.add({
          'translation': bibleId.toUpperCase(),
          'text': 'Error loading: $e',
        });
      }
    }
    
    return results;
  }
  void _showHistoricalContext() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historical Context: $_bookName',
              style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Historical context for individual books is coming soon.'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addNote() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note on $_bookName $_currentChapter'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write your note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final noteVerseId = '${widget.bookId}-$_currentChapter';
              await VerseStorageService.saveNote(
                SavedVerse(
                  id: noteVerseId,
                  bookId: widget.bookId,
                  bookName: _bookName,
                  chapter: _currentChapter,
                  verse: 0,
                  text: '',
                  note: controller.text,
                  savedAt: DateTime.now(),
                  bibleId: CurrentBible.id,
                ),
                controller.text,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeSheet() {
    final settings = ref.read(settingsProvider);
    int fontSize = settings.fontSize;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Text Size', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.text_fields, size: 20),
                    Expanded(
                      child: Slider(
                        value: fontSize.toDouble(),
                        min: 12,
                        max: 32,
                        divisions: 10,
                        onChanged: (value) {
                          setModalState(() => fontSize = value.round());
                        },
                        onChangeEnd: (value) {
                          ref.read(settingsProvider.notifier).setFontSize(value.round());
                        },
                      ),
                    ),
                    Text('$fontSize'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleTheme() {
    final settings = ref.read(settingsProvider);
    final nextMode = settings.isDarkMode ? ReadingMode.day : ReadingMode.night;
    ref.read(settingsProvider.notifier).setReadingMode(nextMode);
  }

  void _checkAudioState() {
    final isPlaying = ref.read(audioBibleProvider).isSpeaking;
    if (_isPlayingAudio != isPlaying) {
      setState(() => _isPlayingAudio = isPlaying);
    }
  }

  Future<void> _playAudio() async {
    debugPrint('AUDIO: _playAudio tapped');
    final settings = ref.read(settingsProvider);
    if (!settings.audioEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio is disabled in Settings, attempting playback anyway...')),
      );
    }

    final audioNotifier = ref.read(audioBibleProvider.notifier);
    final audioState = ref.read(audioBibleProvider);
    if (audioState.isSpeaking) {
      await audioNotifier.stopSpeaking();
      setState(() => _isPlayingAudio = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio stopped')),
        );
      }
      return;
    }

    final cacheKey = _getCacheKey(CurrentBible.id, _currentChapter);
    final fallbackKey = _getCacheKey(_currentBibleId, _currentChapter);
    String? content = _chapterCache[cacheKey] ?? _chapterCache[fallbackKey];

    // If cache is empty, fetch directly before failing audio.
    if (content == null || content.trim().isEmpty) {
      try {
        content = await DirectBibleLoader.getChapter(
          CurrentBible.id,
          widget.bookId,
          _currentChapter,
        );
        content ??= await DirectBibleLoader.getChapter('kjv', widget.bookId, _currentChapter);
        if (content != null && content.isNotEmpty && mounted) {
          setState(() {
            _chapterCache[cacheKey] = content!;
          });
        }
      } catch (e) {
        debugPrint('Failed to load chapter content: $e');
      }
    }

    if (content == null || content.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chapter not loaded yet')),
        );
      }
      return;
    }

    final verseTexts = <String>[];
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('[')) continue;

      final match = RegExp(r'^(\d+)\s+(.+)$').firstMatch(trimmed);
      if (match != null) {
        verseTexts.add('${match.group(1)}. ${match.group(2)}');
      } else {
        final firstSpace = trimmed.indexOf(' ');
        if (firstSpace != -1) {
          final firstPart = trimmed.substring(0, firstSpace).replaceAll('.', '').trim();
          if (int.tryParse(firstPart) != null) {
            verseTexts.add(trimmed);
          }
        }
      }
    }

    if (verseTexts.isEmpty && content.trim().isNotEmpty) {
      verseTexts.add(content.trim());
    }

    if (verseTexts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No verse text found to play.')),
        );
      }
      return;
    }

    try {
      debugPrint('AUDIO: playing ${verseTexts.length} verses, content len: ${content.length}');
      await audioNotifier.speakChapter(
        verseTexts,
        '$_bookName $_currentChapter',
      );
      setState(() => _isPlayingAudio = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing audio (${verseTexts.length} verses)...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio failed to start: $e')),
        );
      }
    }
  }

  Future<void> _bookmarkCurrentVerse() async {
    try {
      final content = _chapterCache[_getCacheKey(CurrentBible.id, _currentChapter)] ??
          _chapterCache[_getCacheKey(_currentBibleId, _currentChapter)] ??
          '';

      final firstVerseMatch = RegExp(r'^(\d+)\s+(.+)$', multiLine: true).firstMatch(content);
      final verseNum = firstVerseMatch != null ? int.parse(firstVerseMatch.group(1)!) : 1;
      final verseText = firstVerseMatch?.group(2) ?? '';

      final verseId = '${CurrentBible.id}:${widget.bookId}:$_currentChapter:$verseNum';
      final savedVerse = SavedVerse(
        id: verseId,
        bookId: widget.bookId,
        bookName: _bookName,
        chapter: _currentChapter,
        verse: verseNum,
        text: verseText,
        bibleId: CurrentBible.id,
        savedAt: DateTime.now(),
      );

      await VerseStorageService.initialize();
      final already = VerseStorageService.isBookmarked(verseId);
      if (already) {
        await VerseStorageService.removeBookmark(verseId);
      } else {
        await VerseStorageService.addBookmark(savedVerse);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(already ? 'Bookmark removed' : 'Bookmarked ${savedVerse.reference}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to bookmark: $e')),
        );
      }
    }
  }
}


class _TranslationCard extends StatelessWidget {
  final String translation;
  final String text;

  const _TranslationCard({
    required this.translation,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                translation,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

