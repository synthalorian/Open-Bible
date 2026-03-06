import 'package:flutter/material.dart';
import 'core/services/verse_storage_service.dart';

/// Debug page to check storage
class DebugStoragePage extends StatefulWidget {
  const DebugStoragePage({super.key});

  @override
  State<DebugStoragePage> createState() => _DebugStoragePageState();
}

class _DebugStoragePageState extends State<DebugStoragePage> {
  Map<String, dynamic> _debugData = {};
  String _error = '';
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDebugData();
  }
  
  Future<void> _loadDebugData() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      debugPrint('\n🔍 DEBUG: Loading storage data...');
      
      // Check if initialized
      debugPrint('  Initialized: ${VerseStorageService.isInitialized}');
      
      // Use VerseStorageService snapshot instead of direct SharedPreferences access.
      final storageKeys = VerseStorageService.debugStorageSnapshot();
      debugPrint('  Storage snapshot keys: ${storageKeys.length}');
      
      // Get cached data
      final bookmarks = VerseStorageService.bookmarksCache;
      final highlights = VerseStorageService.highlightsCache;
      final notes = VerseStorageService.notesCache;
      
      debugPrint('  Bookmarks in cache: ${bookmarks.length}');
      debugPrint('  Highlights in cache: ${highlights.length}');
      debugPrint('  Notes in cache: ${notes.length}');
      
      if (mounted) {
        setState(() {
          _debugData = {
            'Status': {
              'Initialized': VerseStorageService.isInitialized,
            },
            'Storage Keys': storageKeys,
            'Bookmarks Count': bookmarks.length,
            'Bookmarks': bookmarks.map((b) => '${b.reference} (${b.id})').toList(),
            'Highlights Count': highlights.length,
            'Highlights': highlights.entries.map((e) => '${e.key}: ${e.value.highlightColor}').toList(),
            'Notes Count': notes.length,
            'Notes': notes.entries.map((e) => '${e.key}: ${e.value.note?.substring(0, e.value.note!.length > 30 ? 30 : e.value.note!.length)}...').toList(),
          };
          _loading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('✗ ERROR in debug page: $e');
      debugPrint('Stack: $stack');
      if (mounted) {
        setState(() {
          _error = '$e\n\n$stack';
          _loading = false;
        });
      }
    }
  }
  
  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will remove all bookmarks, highlights, and notes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await VerseStorageService.clearAll();
      await _loadDebugData();
    }
  }
  
  Future<void> _addTestBookmark() async {
    final verse = SavedVerse(
      id: 'test_genesis_1_1',
      bookId: 'genesis',
      bookName: 'Genesis',
      chapter: 1,
      verse: 1,
      text: 'In the beginning God created the heaven and the earth.',
      savedAt: DateTime.now(),
      bibleId: 'kjv',
    );
    
    debugPrint('\n🧪 Adding test bookmark...');
    await VerseStorageService.addBookmark(verse);
    debugPrint('  Result: SUCCESS');
    
    await _loadDebugData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Test Bookmark'),
                    onPressed: _addTestBookmark,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Error display
                  if (_error.isNotEmpty)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ERROR',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error,
                              style: const TextStyle(
                                color: Colors.red,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Data display
                  ..._debugData.entries.map((entry) => 
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (entry.value is List)
                              ...(entry.value as List).map((e) => Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Text('• $e'),
                              ))
                            else if (entry.value is Map)
                              ...(entry.value as Map).entries.map((e) => Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Text('• ${e.key}: ${e.value}'),
                              ))
                            else
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text('${entry.value}'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
