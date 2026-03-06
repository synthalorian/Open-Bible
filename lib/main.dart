import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
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
    return MaterialApp(
      title: 'Open Bible',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
    const SearchPage(),
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

/// Bible Page - Main reader
class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  List<BibleBook> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBibleData();
  }

  Future<void> _loadBibleData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/bible_data/kjv_bible.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> booksJson = data['books'];
      
      setState(() {
        _books = booksJson.map((json) => BibleBook.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
      appBar: AppBar(title: const Text('Open Bible')),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            title: Text(book.name),
            subtitle: Text('${book.chapters.length} chapters'),
            onTap: () => _openBook(book),
          );
        },
      ),
    );
  }
  
  void _openBook(BibleBook book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChapterListPage(book: book)),
    );
  }
}

/// Chapter List Page
class ChapterListPage extends StatelessWidget {
  final BibleBook book;
  const ChapterListPage({super.key, required this.book});

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
            onTap: () => _openChapter(context, chapter),
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
  
  void _openChapter(BuildContext context, BibleChapter chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterReaderPage(
          bookName: book.name,
          chapter: chapter,
        ),
      ),
    );
  }
}

/// Chapter Reader Page
class ChapterReaderPage extends StatelessWidget {
  final String bookName;
  final BibleChapter chapter;
  
  const ChapterReaderPage({
    super.key,
    required this.bookName,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$bookName ${chapter.chapter}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chapter.verses.length,
        itemBuilder: (context, index) {
          final verse = chapter.verses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontSize: 18,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '${verse.verse} ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(text: verse.text),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Search Page - Search across all Bible verses
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final String jsonString = await rootBundle.loadString('assets/bible_data/kjv_bible.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> booksJson = data['books'];
      
      final results = <SearchResult>[];
      final lowerQuery = query.toLowerCase();
      
      for (final bookJson in booksJson) {
        final bookName = bookJson['name'] as String;
        final bookId = bookJson['id'] as String;
        final chapters = bookJson['chapters'] as List;
        
        for (final chapter in chapters) {
          final chapterNum = chapter['chapter'] as int;
          final verses = chapter['verses'] as List;
          
          for (final verse in verses) {
            final verseNum = verse['verse'] as int;
            final text = verse['text'] as String;
            
            if (text.toLowerCase().contains(lowerQuery)) {
              results.add(SearchResult(
                bookId: bookId,
                bookName: bookName,
                chapter: chapterNum,
                verse: verseNum,
                text: text,
                query: query,
              ));
            }
          }
        }
      }
      
      setState(() {
        _results = results;
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
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Bible...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          style: const TextStyle(fontSize: 18),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Enter a word or phrase to search', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No results found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return SearchResultTile(result: result);
      },
    );
  }
}

/// Search result model
class SearchResult {
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String query;

  SearchResult({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.query,
  });

  String get reference => '$bookName $chapter:$verse';
}

/// Search result tile with highlighted text
class SearchResultTile extends StatelessWidget {
  final SearchResult result;
  
  const SearchResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final lowerText = result.text.toLowerCase();
    final lowerQuery = result.query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    
    List<TextSpan> spans = [];
    if (index >= 0) {
      // Before match
      if (index > 0) {
        spans.add(TextSpan(text: result.text.substring(0, index)));
      }
      // Match
      spans.add(TextSpan(
        text: result.text.substring(index, index + result.query.length),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.yellow,
        ),
      ));
      // After match
      if (index + result.query.length < result.text.length) {
        spans.add(TextSpan(text: result.text.substring(index + result.query.length)));
      }
    } else {
      spans.add(TextSpan(text: result.text));
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          result.reference,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: spans,
          ),
        ),
        onTap: () => _openVerse(context),
      ),
    );
  }

  void _openVerse(BuildContext context) {
    // TODO: Navigate to the specific verse in the reader
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${result.reference}...')),
    );
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Saved - Coming Soon')),
  );
}

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Plans - Coming Soon')),
  );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: const Text('Genealogy'),
            subtitle: const Text('Biblical family tree'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GenealogyPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Genealogy Page
class GenealogyPage extends StatelessWidget {
  const GenealogyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblical Genealogy')),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/data/genealogy_data.json'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading genealogy'));
          }
          
          final data = json.decode(snapshot.data!);
          final people = (data['people'] as List).cast<Map<String, dynamic>>();
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(person['name']),
                  subtitle: Text('${person['description']}\nBorn: ${person['birthYear']}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Bible Models
class BibleBook {
  final String id;
  final String name;
  final List<BibleChapter> chapters;
  
  BibleBook({
    required this.id,
    required this.name,
    required this.chapters,
  });
  
  factory BibleBook.fromJson(Map<String, dynamic> json) => BibleBook(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    chapters: (json['chapters'] as List? ?? [])
        .map((c) => BibleChapter.fromJson(c))
        .toList(),
  );
}

class BibleChapter {
  final int chapter;
  final List<BibleVerse> verses;
  
  BibleChapter({required this.chapter, required this.verses});
  
  factory BibleChapter.fromJson(Map<String, dynamic> json) => BibleChapter(
    chapter: json['chapter'] ?? 0,
    verses: (json['verses'] as List? ?? [])
        .map((v) => BibleVerse.fromJson(v))
        .toList(),
  );
}

class BibleVerse {
  final int verse;
  final String text;
  
  BibleVerse({required this.verse, required this.text});
  
  factory BibleVerse.fromJson(Map<String, dynamic> json) => BibleVerse(
    verse: json['verse'] ?? 0,
    text: json['text'] ?? '',
  );
}
