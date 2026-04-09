import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/chapter_reader_page.dart';
import '../pages/book_chapters_page.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/continue_reading_service.dart';
import '../../../../core/config/bible_translations.dart';
import '../widgets/continue_reading_card.dart';

/// Simple translation selector that actually works
class TranslationSelector extends ConsumerStatefulWidget {
  final String currentTranslationId;
  final Function(String) onTranslationChanged;
  
  const TranslationSelector({
    super.key,
    required this.currentTranslationId,
    required this.onTranslationChanged,
  });

  @override
  ConsumerState<TranslationSelector> createState() => _TranslationSelectorState();
}

class _TranslationSelectorState extends ConsumerState<TranslationSelector> {
  @override
  Widget build(BuildContext context) {
    final currentAbbr = BibleTranslations.getAbbreviation(widget.currentTranslationId);
    final downloadManager = ref.watch(bibleDownloadManagerProvider);

    return PopupMenuButton<String>(
      initialValue: widget.currentTranslationId,
      onSelected: (value) async {
        debugPrint('PopupMenu selected: $value');
        
        // Check if downloaded
        if (!downloadManager.isVersionAvailable(value)) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Download ${value.toUpperCase()}?'),
              content: Text('This translation needs to be downloaded for offline use.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Download'),
                ),
              ],
            ),
          );
          
          if (confirm == true) {
            // Show loading snackbar
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading ${value.toUpperCase()}...')),
            );

            final success = await downloadManager.downloadVersion(value);
            if (success) {
              widget.onTranslationChanged(value);
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download failed. Check your connection.')),
              );
            }
          }
        } else {
          widget.onTranslationChanged(value);
        }
      },
      itemBuilder: (context) {
        // Group by category
        final categories = ['Historical', 'Classic', 'Modern'];
        final items = <PopupMenuEntry<String>>[];
        
        for (final category in categories) {
          items.add(PopupMenuDivider());
          items.add(PopupMenuItem(
            enabled: false,
            child: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ));
          
          for (final t in BibleTranslations.getByCategory(category)) {
            final isDownloaded = downloadManager.isVersionAvailable(t.id);
            
            items.add(PopupMenuItem(
              value: t.id,
              child: Row(
                children: [
                  if (t.id == widget.currentTranslationId)
                    const Icon(Icons.check, color: Colors.green, size: 20)
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  Text(t.abbreviation),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '(${t.year})',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                  if (!isDownloaded)
                    Icon(Icons.download, size: 16, color: Theme.of(context).colorScheme.outline),
                ],
              ),
            ));
          }
        }
        
        return items;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentAbbr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_drop_down, size: 24),
        ],
      ),
    );
  }
}

/// Bible home page - shows list of books
class BibleHomePage extends ConsumerStatefulWidget {
  const BibleHomePage({super.key});

  @override
  ConsumerState<BibleHomePage> createState() => _BibleHomePageState();
}

class _BibleHomePageState extends ConsumerState<BibleHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ContinueReadingData? _lastPosition;
  String _selectedTranslationId = 'kjv';
  bool _hasLoadedContinueReading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContinueReading();
    
    // Get initial translation from provider
    final bibleData = ref.read(bibleDataProvider);
    _selectedTranslationId = bibleData.selectedTranslation?.id ?? 'kjv';
  }
  
  void _loadContinueReading() {
    try {
      _lastPosition = ContinueReadingService.getLastPosition();
    } catch (e) {
      debugPrint('Error loading continue reading: $e');
      _lastPosition = null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedContinueReading) {
      _hasLoadedContinueReading = true;
      _loadContinueReading();
    }
  }

  void _onTranslationChanged(String newId) {
    debugPrint('Translation changed to: $newId');
    
    // Update provider (this also syncs CurrentBible internally)
    ref.read(bibleDataProvider.notifier).selectTranslation(newId);
    
    // Update local state
    setState(() {
      _selectedTranslationId = newId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: TranslationSelector(
          currentTranslationId: _selectedTranslationId,
          onTranslationChanged: _onTranslationChanged,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () => _showHistory(context),
          ),
          IconButton(
            icon: Icon(settings.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              final nextMode = settings.isDarkMode ? ReadingMode.day : ReadingMode.night;
              ref.read(settingsProvider.notifier).setReadingMode(nextMode);
            },
          ),
        ],
      ),
      body: _buildBody(settings),
    );
  }
  
  Widget _buildBody(AppSettings settings) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search books...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        
        // Continue Reading
        _buildContinueReadingCard(),
        
        // Book list with tabs
        Expanded(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
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
                  controller: _tabController,
                  children: [
                    _buildBookList(BibleStructure.oldTestament),
                    _buildBookList(BibleStructure.newTestament),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _normalizeBookRouteId(String bookId, String bookName) {
    final normalizedByName = bookName.toLowerCase();
    if (BibleStructure.allBooks.any((b) => b.toLowerCase() == normalizedByName)) {
      return normalizedByName;
    }

    final compactId = bookId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final b in BibleStructure.allBooks) {
      final lower = b.toLowerCase();
      final compact = lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (compact == compactId || compact.startsWith(compactId) || compactId.startsWith(compact)) {
        return lower;
      }
    }

    return normalizedByName;
  }

  Widget _buildContinueReadingCard() {
    final data = _lastPosition;
    if (data == null) return const SizedBox.shrink();

    final routeBookId = _normalizeBookRouteId(data.bookId, data.bookName);
    
    return ContinueReadingCard(
      data: data,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChapterReaderPage(
            bookId: routeBookId,
            chapter: data.chapter,
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(List<String> books) {
    final filtered = _searchQuery.isEmpty
        ? books
        : books.where((b) => b.toLowerCase().contains(_searchQuery)).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final book = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(book[0])),
            title: Text(book, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${BibleStructure.getChapterCount(book)} chapters'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookChaptersPage(bookId: book.toLowerCase()),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Center(child: Text('History coming soon')),
    );
  }

}
