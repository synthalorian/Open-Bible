import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/continue_reading_service.dart';

/// Card widget showing continue reading progress
class ContinueReadingCard extends StatelessWidget {
  final ContinueReadingData data;
  final VoidCallback? onTap;
  
  const ContinueReadingCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Continue Reading',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (data.timeAgo.isNotEmpty)
                    Text(
                      data.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.reference,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.bibleName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await ContinueReadingService.clear();
                      // Notify parent to refresh
                      if (context.mounted) {
                        // Use a callback to parent or setState equivalent
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reading history cleared')),
                        );
                        // Trigger rebuild by popping and returning
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state when no reading history
class EmptyContinueReadingCard extends StatelessWidget {
  const EmptyContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Reading',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your reading progress will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
