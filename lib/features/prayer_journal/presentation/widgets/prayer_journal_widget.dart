import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

/// Prayer journal widget
class PrayerJournalWidget extends ConsumerWidget {
  final bool showAnswered;
  
  const PrayerJournalWidget({
    super.key,
    this.showAnswered = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerJournalProvider);
    final prayers = showAnswered
        ? prayerState.answeredPrayers
        : prayerState.activePrayers;
    
    if (prayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showAnswered ? Icons.check_circle_outline : Icons.favorite,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              showAnswered
                  ? 'No answered prayers yet'
                  : 'No active prayers',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              showAnswered
                  ? 'Your answered prayers will appear here'
                  : 'Add your first prayer',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final prayer = prayers[index];
        return PrayerCard(prayer: prayer);
      },
    );
  }
}

/// Prayer card widget
class PrayerCard extends ConsumerWidget {
  final PrayerEntry prayer;
  
  const PrayerCard({
    super.key,
    required this.prayer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  prayer.isAnswered
                      ? Icons.check_circle
                      : Icons.access_time,
                  color: prayer.isAnswered
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(prayer.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAction(context, ref, value),
                  itemBuilder: (context) => [
                    if (!prayer.isAnswered)
                      const PopupMenuItem(
                        value: 'answer',
                        child: ListTile(
                          leading: Icon(Icons.check),
                          title: Text('Mark as Answered'),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prayer.text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (prayer.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: prayer.tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            if (prayer.isAnswered && prayer.answeredAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Answered on ${_formatDate(prayer.answeredAt!)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (prayer.notes != null && prayer.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prayer.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'answer':
        _showAnswerDialog(context, ref);
        break;
      case 'edit':
        _showEditDialog(context, ref);
        break;
      case 'delete':
        _confirmDelete(context, ref);
        break;
    }
  }
  
  void _showAnswerDialog(BuildContext context, WidgetRef ref) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Answered'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add notes about how God answered this prayer...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(prayerJournalProvider.notifier).markAsAnswered(
                prayer.id,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
              Navigator.pop(context);
            },
            child: const Text('Mark Answered'),
          ),
        ],
      ),
    );
  }
  
  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController(text: prayer.text);
    final notesController = TextEditingController(text: prayer.notes);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Prayer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Prayer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedPrayer = prayer.copyWith(
                text: textController.text,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
              ref.read(prayerJournalProvider.notifier).updatePrayer(updatedPrayer);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prayer?'),
        content: const Text('Are you sure you want to delete this prayer? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(prayerJournalProvider.notifier).deletePrayer(prayer.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Add prayer FAB
class AddPrayerFAB extends ConsumerWidget {
  const AddPrayerFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddPrayerDialog(context, ref),
      icon: const Icon(Icons.add),
      label: const Text('Add Prayer'),
    );
  }
  
  void _showAddPrayerDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    final tagsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Prayer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Prayer Request',
                border: OutlineInputBorder(),
                hintText: 'Enter your prayer...',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., family, healing, guidance',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                final tags = tagsController.text
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();
                
                ref.read(prayerJournalProvider.notifier).addPrayer(
                  textController.text,
                  tags: tags.isNotEmpty ? tags : null,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Prayer stats card
class PrayerStatsCard extends ConsumerWidget {
  const PrayerStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerJournalProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(
              context,
              'Total',
              prayerState.totalPrayers,
              Icons.format_list_numbered,
            ),
            _buildStat(
              context,
              'Active',
              prayerState.totalActive,
              Icons.access_time,
              color: Theme.of(context).colorScheme.primary,
            ),
            _buildStat(
              context,
              'Answered',
              prayerState.totalAnswered,
              Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(
    BuildContext context,
    String label,
    int value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
