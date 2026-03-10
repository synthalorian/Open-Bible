import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

/// Daily devotional widget
class DailyDevotionalWidget extends ConsumerWidget {
  final bool compact;
  
  const DailyDevotionalWidget({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devotionalState = ref.watch(devotionalProvider);
    final devotional = devotionalState.todayDevotional;
    
    if (devotionalState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (devotional == null) {
      return const SizedBox.shrink();
    }
    
    if (compact) {
      return _buildCompactCard(context, ref, devotional);
    }
    
    return _buildFullCard(context, ref, devotional);
  }
  
  Widget _buildCompactCard(BuildContext context, WidgetRef ref, DevotionalEntry devotional) {
    final isSaved = ref.watch(devotionalProvider).savedDevotionals.any((d) => d.id == devotional.id);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _showFullDevotional(context, devotional),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Devotional',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      size: 20,
                      color: isSaved
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      if (isSaved) {
                        ref.read(devotionalProvider.notifier).unsaveDevotional(devotional.id);
                      } else {
                        ref.read(devotionalProvider.notifier).saveDevotional(devotional);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                devotional.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                devotional.scripture,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                devotional.verseReference,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFullCard(BuildContext context, WidgetRef ref, DevotionalEntry devotional) {
    final isSaved = ref.watch(devotionalProvider).savedDevotionals.any((d) => d.id == devotional.id);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Daily Devotional',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: isSaved
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: () {
                    if (isSaved) {
                      ref.read(devotionalProvider.notifier).unsaveDevotional(devotional.id);
                    } else {
                      ref.read(devotionalProvider.notifier).saveDevotional(devotional);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              devotional.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    devotional.scripture,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    devotional.verseReference,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              devotional.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            if (devotional.author != null) ...[
              const SizedBox(height: 16),
              Text(
                '— ${devotional.author}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (devotional.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: devotional.tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _showFullDevotional(BuildContext context, DevotionalEntry devotional) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevotionalDetailPage(devotional: devotional),
      ),
    );
  }
}

/// Devotional detail page
class DevotionalDetailPage extends ConsumerWidget {
  final DevotionalEntry devotional;
  
  const DevotionalDetailPage({
    super.key,
    required this.devotional,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(devotionalProvider).savedDevotionals.any((d) => d.id == devotional.id);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(devotional.title),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: isSaved
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () {
              if (isSaved) {
                ref.read(devotionalProvider.notifier).unsaveDevotional(devotional.id);
              } else {
                ref.read(devotionalProvider.notifier).saveDevotional(devotional);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality would go here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: DailyDevotionalWidget(compact: false),
      ),
    );
  }
}

/// Recent devotionals list
class RecentDevotionalsWidget extends ConsumerWidget {
  const RecentDevotionalsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devotionals = ref.watch(devotionalProvider).recentDevotionals;
    
    if (devotionals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Devotionals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: devotionals.length,
          itemBuilder: (context, index) {
            final devotional = devotionals[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(devotional.title),
              subtitle: Text(devotional.verseReference),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DevotionalDetailPage(devotional: devotional),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
