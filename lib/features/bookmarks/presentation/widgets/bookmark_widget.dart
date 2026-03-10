import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

/// Bookmark button widget
class BookmarkButton extends ConsumerWidget {
  final String verseId;
  final String verseText;
  final String? reference;
  
  const BookmarkButton({
    super.key,
    required this.verseId,
    required this.verseText,
    this.reference,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarksProvider).contains(verseId);
    
    return IconButton(
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
        color: isBookmarked
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: () {
        if (isBookmarked) {
          ref.read(bookmarksProvider.notifier).removeBookmark(verseId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark removed'),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ref.read(bookmarksProvider.notifier).addBookmark(verseId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark added'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
    );
  }
}

/// Bookmarks list widget
class BookmarksListWidget extends ConsumerWidget {
  const BookmarksListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    
    if (bookmarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Bookmark verses to find them here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final verseId = bookmarks[index];
        return Dismissible(
          key: Key(verseId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            ref.read(bookmarksProvider.notifier).removeBookmark(verseId);
          },
          child: ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(verseId),
            subtitle: Text('Tap to open'),
            onTap: () {
              // Navigate to verse would be implemented here
            },
          ),
        );
      },
    );
  }
}

/// Bookmarks page
class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks (${bookmarks.length})'),
        actions: [
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _showClearDialog(context, ref),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: const BookmarksListWidget(),
    );
  }
  
  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks?'),
        content: const Text('This will remove all your bookmarks. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarksProvider.notifier).clearBookmarks();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
