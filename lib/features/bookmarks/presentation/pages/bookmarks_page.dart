import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/verse_storage_service.dart';

/// Saved page - bookmarks, highlights, and notes
class BookmarksPage extends ConsumerStatefulWidget {
  const BookmarksPage({super.key});

  @override
  ConsumerState<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends ConsumerState<BookmarksPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<SavedVerse> _bookmarks = [];
  List<SavedVerse> _highlights = [];
  List<SavedVerse> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload data when app comes back to foreground
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await VerseStorageService.initialize();

      final bookmarks = VerseStorageService.getBookmarks();
      final highlightsMap = VerseStorageService.getHighlights();
      final notesMap = VerseStorageService.getNotes();

      final providerBookmarks = ref.read(bookmarksProvider);
      final providerHighlights = ref.read(highlightsProvider);
      final providerNotes = ref.read(notesProvider);

      // Backward compatibility: merge legacy bookmarks list used by older UI paths
      List<String> legacyBookmarks = const [];
      try {
        final prefs = await SharedPreferences.getInstance();
        legacyBookmarks = prefs.getStringList('bookmarks') ?? const [];
      } catch (_) {
        // SharedPreferences plugin may be unavailable on some builds; keep provider/storage fallback.
      }

      final mergedBookmarks = <SavedVerse>[...bookmarks];
      for (final id in [...legacyBookmarks, ...providerBookmarks]) {
        final exists = mergedBookmarks.any((b) => b.id == id);
        if (!exists) {
          mergedBookmarks.add(_savedVerseFromLegacyId(id));
        }
      }

      final mergedHighlights = <SavedVerse>[...highlightsMap.values];
      for (final entry in providerHighlights.entries) {
        final exists = mergedHighlights.any((h) => h.id == entry.key);
        if (!exists) {
          mergedHighlights.add(
            _savedVerseFromLegacyId(entry.key).copyWith(highlightColor: entry.value),
          );
        }
      }

      final mergedNotes = <SavedVerse>[...notesMap.values];
      for (final entry in providerNotes.entries) {
        final exists = mergedNotes.any((n) => n.id == entry.key);
        if (!exists) {
          mergedNotes.add(
            _savedVerseFromLegacyId(entry.key).copyWith(note: entry.value),
          );
        }
      }

      if (mounted) {
        setState(() {
          _bookmarks = mergedBookmarks;
          _highlights = mergedHighlights;
          _notes = mergedNotes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<String>>(bookmarksProvider, (_, __) => _loadData());
    ref.listen<Map<String, String>>(highlightsProvider, (_, __) => _loadData());
    ref.listen<Map<String, String>>(notesProvider, (_, __) => _loadData());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Bookmarks (${_bookmarks.length})'),
            Tab(text: 'Highlights (${_highlights.length})'),
            Tab(text: 'Notes (${_notes.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookmarksTab(),
                _buildHighlightsTab(),
                _buildNotesTab(),
              ],
            ),
    );
  }

  Widget _buildBookmarksTab() {
    if (_bookmarks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline,
        title: 'No bookmarks yet',
        subtitle: 'Tap on a verse to bookmark it',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _bookmarks[index];
        return Dismissible(
          key: Key(bookmark.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) async {
            await VerseStorageService.removeBookmark(bookmark.id);
            _loadData();
          },
          child: _SavedVerseCard(
            verse: bookmark,
            icon: Icons.bookmark,
            iconColor: Theme.of(context).colorScheme.primary,
            onTap: () => _openVerse(bookmark),
          ),
        );
      },
    );
  }

  Widget _buildHighlightsTab() {
    if (_highlights.isEmpty) {
      return _buildEmptyState(
        icon: Icons.highlight_outlined,
        title: 'No highlights yet',
        subtitle: 'Tap on a verse to highlight it',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _highlights.length,
      itemBuilder: (context, index) {
        final highlight = _highlights[index];
        final colorValue = HighlightColors.getColorValue(highlight.highlightColor ?? 'yellow');
        
        return Dismissible(
          key: Key(highlight.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) async {
            await VerseStorageService.removeHighlight(highlight.id);
            _loadData();
          },
          child: _SavedVerseCard(
            verse: highlight,
            icon: Icons.highlight,
            iconColor: Color(colorValue),
            onTap: () => _openVerse(highlight),
          ),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    if (_notes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_alt_outlined,
        title: 'No notes yet',
        subtitle: 'Tap on a verse to add a note',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Dismissible(
          key: Key(note.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) async {
            await VerseStorageService.removeNote(note.id);
            _loadData();
          },
          child: _SavedVerseCard(
            verse: note,
            icon: Icons.note,
            iconColor: Theme.of(context).colorScheme.secondary,
            showNote: true,
            onTap: () => _openVerse(note),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  SavedVerse _savedVerseFromLegacyId(String id) {
    final match = RegExp(r'^(.*?)\s+(\d+):(\d+)$').firstMatch(id);
    if (match != null) {
      final bookName = match.group(1) ?? 'Unknown';
      final chapter = int.tryParse(match.group(2) ?? '1') ?? 1;
      final verse = int.tryParse(match.group(3) ?? '1') ?? 1;
      return SavedVerse(
        id: id,
        bookId: bookName.replaceAll(' ', '').toUpperCase(),
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: 'Saved from legacy bookmark list',
        savedAt: DateTime.now(),
        bibleId: 'kjv',
      );
    }

    return SavedVerse(
      id: id,
      bookId: 'UNK',
      bookName: 'Unknown',
      chapter: 1,
      verse: 1,
      text: 'Saved from legacy bookmark list',
      savedAt: DateTime.now(),
      bibleId: 'kjv',
    );
  }

  void _openVerse(SavedVerse verse) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open ${verse.reference} from Bible tab for now.')),
    );
  }
}

/// Card widget for displaying a saved verse
class _SavedVerseCard extends StatelessWidget {
  final SavedVerse verse;
  final IconData icon;
  final Color iconColor;
  final bool showNote;
  final VoidCallback onTap;

  const _SavedVerseCard({
    required this.verse,
    required this.icon,
    required this.iconColor,
    this.showNote = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          verse.reference,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(verse.savedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verse.highlightText != null && verse.highlightText!.isNotEmpty
                    ? verse.highlightText!
                    : verse.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              if (verse.highlightStart != null && verse.highlightEnd != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Range: ${verse.highlightStart}-${verse.highlightEnd}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
              if (showNote && verse.note != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          verse.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
