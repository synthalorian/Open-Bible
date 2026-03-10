import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiblePage extends ConsumerWidget {
  const BiblePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Reader'),
        actions: [
          // Bookmark Button
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: () async {
              // Add current verse to bookmarks
              // You would need to implement logic to get the current verse
              // For example:
              // final currentVerse = 'John 3:16';
              // ref.read(bookmarksProvider.notifier).addBookmark(currentVerse);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select a verse to bookmark'),
            const SizedBox(height: 16),
            const Text('Verse 1'),
            const SizedBox(height: 8),
            const Text('Verse 2'),
            const SizedBox(height: 8),
            const Text('Verse 3'),
          ],
        ),
      ),
    );
  }
}
