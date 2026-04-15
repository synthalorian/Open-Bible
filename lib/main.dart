import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'core/models/parsed_bible.dart';
import 'core/providers/app_providers.dart';
import 'core/services/footnote_service.dart';
import 'core/services/verse_storage_service.dart';
import 'core/services/continue_reading_service.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'features/bible/presentation/widgets/translation_selector_widget.dart';
import 'features/bible/presentation/pages/book_chapter_grid_page.dart';
import 'features/bookmarks/presentation/pages/bookmarks_page.dart';

import 'features/reading_plans/presentation/pages/reading_plans_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/search/presentation/pages/search_page.dart' as search_feature;
import 'features/more/presentation/pages/more_page.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services separately so one failure doesn't block others
  try {
    await FootnoteService().initialize();
  } catch (e) {
    logDebug('FootnoteService Init Error: $e');
  }
  try {
    await VerseStorageService.initialize();
  } catch (e) {
    logDebug('VerseStorageService Init Error: $e');
  }
  try {
    await ContinueReadingService.init();
  } catch (e) {
    logDebug('ContinueReadingService Init Error: $e');
  }
  
  runApp(
    const ProviderScope(
      child: OpenBibleApp(),
    ),
  );
}

class OpenBibleApp extends ConsumerWidget {
  const OpenBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    // Select theme based on reading mode
    final ThemeData theme;
    final ThemeMode themeMode;
    
    switch (settings.readingMode) {
      case ReadingMode.day:
        theme = AppTheme.lightTheme;
        themeMode = ThemeMode.light;
        break;
      case ReadingMode.night:
        theme = AppTheme.darkTheme;
        themeMode = ThemeMode.dark;
        break;
      case ReadingMode.sepia:
        theme = AppTheme.sepiaTheme;
        themeMode = ThemeMode.light;
        break;
      case ReadingMode.amoled:
        theme = AppTheme.amoledTheme;
        themeMode = ThemeMode.dark;
        break;
      case ReadingMode.synthwave:
        theme = AppTheme.synthwaveTheme;
        themeMode = ThemeMode.dark;
        break;
    }
    
    return MaterialApp(
      title: 'Open Bible',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigationPage(),
    );
  }
}

/// Main navigation with bottom tabs
class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _currentIndex = 0;
  
  final _pages = [
    const BiblePage(),
    const search_feature.SearchPage(),
    const SavedPage(),
    const PlansPage(),
    const MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Bible'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Plans'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

/// Bible Page - Main reader with translation support
class BiblePage extends ConsumerStatefulWidget {
  const BiblePage({super.key});

  @override
  ConsumerState<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends ConsumerState<BiblePage> {
  List<ParsedBibleBook> _books = [];
  bool _isLoading = true;
  String _currentTranslation = '';

  @override
  void initState() {
    super.initState();
    // Initialize providers
    Future.delayed(Duration.zero, () async {
      await ref.read(bookmarksProvider.notifier).init();
      await ref.read(highlightsProvider.notifier).init();
      await ref.read(notesProvider.notifier).init();
      await _loadBibleDataFor(ref.read(selectedTranslationProvider));
    });
    // Listen for translation changes after initial load
    ref.listenManual(selectedTranslationProvider, (previous, next) {
      if (previous != next) {
        _loadBibleDataFor(next);
      }
    });
  }

  Future<void> _loadBibleDataFor(String translationId) async {
    if (_currentTranslation == translationId && !_isLoading && _books.isNotEmpty) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _currentTranslation = translationId;
      });
    }

    try {
      final jsonString = await rootBundle.loadString('assets/bible_data/${translationId}_bible.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final booksJson = data['books'] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _books = booksJson.map((j) => ParsedBibleBook.fromJson(j as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      logDebug('Failed to load translation $translationId: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load translation: ${translationId.toUpperCase()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: TranslationSelectorWidget(
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const search_feature.SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'Old Testament'),
                Tab(text: 'New Testament'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBooksListFor(BibleStructure.oldTestament),
                  _buildBooksListFor(BibleStructure.newTestament),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBooksListFor(List<String> testamentBooks) {
    final testamentSet = testamentBooks.map((b) => b.toLowerCase().trim()).toSet();
    final filteredBooks = _books.where((book) {
      return testamentSet.contains(book.name.toLowerCase().trim());
    }).toList();

    return ListView.builder(
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        final book = filteredBooks[index];
        return ListTile(
          title: Text(book.name),
          subtitle: Text('${book.chapters.length} chapters'),
          onTap: () => _openBook(book),
        );
      },
    );
  }

  void _openBook(ParsedBibleBook book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookChapterGridPage(book: book)),
    );
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});
  @override
  Widget build(BuildContext context) => const BookmarksPage();
}

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});
  @override
  Widget build(BuildContext context) => const ReadingPlansPage();
}
