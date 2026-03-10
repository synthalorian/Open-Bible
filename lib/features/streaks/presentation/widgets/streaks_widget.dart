import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

/// Reading streaks widget
class ReadingStreaksWidget extends ConsumerWidget {
  final bool showDetails;
  
  const ReadingStreaksWidget({
    super.key,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaksState = ref.watch(readingStreaksProvider);
    final streaksNotifier = ref.read(readingStreaksProvider.notifier);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current streak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: streaksState.hasReadToday
                      ? Colors.orange
                      : Colors.grey,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${streaksState.currentStreak}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      streaksState.currentStreak == 1 ? 'Day Streak' : 'Day Streak',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (showDetails) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    context,
                    'Longest',
                    '${streaksState.longestStreak}',
                    Icons.emoji_events,
                  ),
                  _buildStat(
                    context,
                    'Total Days',
                    '${streaksState.totalDaysRead}',
                    Icons.calendar_today,
                  ),
                  _buildStat(
                    context,
                    'This Week',
                    '${streaksState.daysThisWeek}',
                    Icons.date_range,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Today's status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: streaksState.hasReadToday
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      streaksState.hasReadToday
                          ? Icons.check_circle
                          : Icons.pending,
                      color: streaksState.hasReadToday
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        streaksState.hasReadToday
                            ? "Great job! You've read today!"
                            : "Don't forget to read today!",
                        style: TextStyle(
                          color: streaksState.hasReadToday
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Mark as read button
              if (!streaksState.hasReadToday) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => streaksNotifier.recordReading(),
                  icon: const Icon(Icons.book),
                  label: const Text('Mark as Read'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
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

/// Compact streak indicator for app bar
class CompactStreakIndicator extends ConsumerWidget {
  const CompactStreakIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaksState = ref.watch(readingStreaksProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: streaksState.hasReadToday
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: streaksState.hasReadToday
                ? Colors.orange
                : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${streaksState.currentStreak}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: streaksState.hasReadToday
                  ? Colors.orange
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekly streak calendar
class WeeklyStreakCalendar extends ConsumerWidget {
  const WeeklyStreakCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaksState = ref.watch(readingStreaksProvider);
    final now = DateTime.now();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final date = now.subtract(Duration(days: now.weekday - 1 - index));
                final hasRead = streaksState.readDates.any((d) =>
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day
                );
                
                return Column(
                  children: [
                    Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: hasRead
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: hasRead
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 16,
                              )
                            : Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
