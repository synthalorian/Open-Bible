import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/providers/app_providers.dart';

/// Prayer journal page - track prayers and answers
class PrayerJournalPage extends ConsumerStatefulWidget {
  const PrayerJournalPage({super.key});

  @override
  ConsumerState<PrayerJournalPage> createState() => _PrayerJournalPageState();
}

class _PrayerJournalPageState extends ConsumerState<PrayerJournalPage> {
  List<PrayerEntry> _entries = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final storage = ref.read(storageServiceProvider);
      if (!storage.isInitialized) {
        await storage.init();
      }
      if (!mounted) return;
      setState(() {
        _entries = storage.getAllPrayerEntries();
      });
    } catch (e) {
      print('Error loading prayer entries: $e');
      if (!mounted) return;
      setState(() {
        _entries = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading prayers: $e')),
        );
      }
    }
  }

  List<PrayerEntry> get _filteredEntries {
    switch (_selectedFilter) {
      case 'active':
        return _entries.where((e) => !e.isAnswered).toList();
      case 'answered':
        return _entries.where((e) => e.isAnswered).toList();
      default:
        return _entries;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Journal'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Prayers'),
              ),
              const PopupMenuItem(
                value: 'active',
                child: Text('Active'),
              ),
              const PopupMenuItem(
                value: 'answered',
                child: Text('Answered'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPrayer(),
        icon: const Icon(Icons.add),
        label: const Text('New Prayer'),
      ),
    );
  }

  Widget _buildBody() {
    final entries = _filteredEntries;
    
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all'
                  ? 'No prayers yet'
                  : 'No ${_selectedFilter} prayers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start recording your prayers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _PrayerCard(
          entry: entry,
          onTap: () => _editPrayer(entry),
          onMarkAnswered: () => _markAnswered(entry),
          onDelete: () => _deletePrayer(entry),
        );
      },
    );
  }

  void _addPrayer() {
    _showPrayerEditor(null);
  }

  void _editPrayer(PrayerEntry entry) {
    _showPrayerEditor(entry);
  }

  void _showPrayerEditor(PrayerEntry? entry) {
    final titleController = TextEditingController(text: entry?.title ?? '');
    final contentController = TextEditingController(text: entry?.content ?? '');
    final tags = entry?.tags.toList() ?? <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry == null ? 'New Prayer' : 'Edit Prayer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What are you praying for?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Prayer',
                  hintText: 'Write your prayer...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  ...tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setModalState(() => tags.remove(tag));
                        },
                      )),
                  ActionChip(
                    label: const Text('+ Add Tag'),
                    onPressed: () => _addTag(tags, setModalState),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await _savePrayer(
                          entry?.id,
                          titleController.text,
                          contentController.text,
                          tags,
                        );
                        if (ok && mounted && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(entry == null ? 'Save' : 'Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag(List<String> tags, StateSetter setModalState) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g., healing, family, work',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setModalState(() => tags.add(controller.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<bool> _savePrayer(
    String? id,
    String title,
    String content,
    List<String> tags,
  ) async {
    if (!mounted) return false;
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return false;
    }

    try {
      final storage = ref.read(storageServiceProvider);
      
      // Try to initialize, but continue even if it fails (will use memory fallback)
      if (!storage.isInitialized) {
        try {
          await storage.init();
        } catch (initError) {
          debugPrint('PRAYER: Storage init failed (will use fallback): $initError');
          // Continue anyway - storage service has memory fallback
        }
      }
      
      final now = DateTime.now();
      
      final entry = PrayerEntry(
        id: id ?? const Uuid().v4(),
        title: title.trim(),
        content: content.trim(),
        tags: tags,
        createdAt: id != null
            ? _entries.firstWhere((e) => e.id == id).createdAt
            : now,
      );
      
      await storage.savePrayerEntry(entry);
      debugPrint('PRAYER: Saved entry ${entry.id}');

      await _loadEntries();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(id == null ? 'Prayer saved!' : 'Prayer updated!')),
        );
      }
      return true;
    } catch (e) {
      debugPrint('PRAYER: Error saving: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save prayer: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _markAnswered(PrayerEntry entry) async {
    final storage = ref.read(storageServiceProvider);
    final updated = entry.copyWith(
      isAnswered: !entry.isAnswered,
      answeredAt: !entry.isAnswered ? DateTime.now() : null,
    );
    await storage.savePrayerEntry(updated);
    _loadEntries();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            entry.isAnswered
                ? 'Prayer marked as active'
                : 'Praise God! 🙏 Prayer marked as answered!',
          ),
        ),
      );
    }
  }

  Future<void> _deletePrayer(PrayerEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prayer?'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storage = ref.read(storageServiceProvider);
      await storage.deletePrayerEntry(entry.id);
      _loadEntries();
    }
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerEntry entry;
  final VoidCallback onTap;
  final VoidCallback onMarkAnswered;
  final VoidCallback onDelete;

  const _PrayerCard({
    required this.entry,
    required this.onTap,
    required this.onMarkAnswered,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  Expanded(
                    child: Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: entry.isAnswered
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                  ),
                  if (entry.isAnswered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✓ Answered',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              if (entry.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: entry.tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    _formatDate(entry.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      entry.isAnswered
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: entry.isAnswered ? Colors.green : null,
                    ),
                    onPressed: onMarkAnswered,
                    tooltip: entry.isAnswered
                        ? 'Mark as active'
                        : 'Mark as answered',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
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
