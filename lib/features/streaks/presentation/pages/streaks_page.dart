import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/storage_service.dart';

/// Streaks page - track reading progress
class StreaksPage extends ConsumerStatefulWidget {
  const StreaksPage({super.key});

  @override
  ConsumerState<StreaksPage> createState() => _StreaksPageState();
}

class _StreaksPageState extends ConsumerState<StreaksPage> {
  StreakData? _streak;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    try {
      final storage = ref.read(storageServiceProvider);
      
      // Ensure storage is initialized
      if (!storage.isInitialized) {
        await storage.init();
      }
      
      final streak = storage.getStreak();

      final currentStreak = streak?.currentStreak ?? 0;
      final longestStreak = streak?.longestStreak ?? 0;
      final totalDays = streak?.totalDaysRead ?? 0;
      final lastRead = streak?.lastReadDate;
      
      if (mounted) {
        setState(() {
          if (lastRead != null && currentStreak > 0) {
            _streak = StreakData(
              currentStreak: currentStreak,
              longestStreak: longestStreak,
              lastReadDate: lastRead,
              totalDaysRead: totalDays,
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading streak: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading streak: $e')),
        );
      }
    }
  }

  Future<void> _recordReading() async {
    try {
      debugPrint('STREAK: Recording reading...');
      final storage = ref.read(storageServiceProvider);
      if (!storage.isInitialized) {
        debugPrint('STREAK: Storage not initialized, calling init...');
        await storage.init();
      }
      final now = DateTime.now();

      final existing = storage.getStreak();
      debugPrint('STREAK: Existing streak: $existing');
      
      final currentStreak = existing?.currentStreak ?? 0;
      final longestStreak = existing?.longestStreak ?? 0;
      final totalDays = existing?.totalDaysRead ?? 0;
      final lastRead = existing?.lastReadDate;
      
      int newCurrentStreak;
      int newLongestStreak;
      int newTotalDays;
      
      if (lastRead == null) {
        // First time
        debugPrint('STREAK: First time recording');
        newCurrentStreak = 1;
        newLongestStreak = 1;
        newTotalDays = 1;
      } else {
        final lastDay = DateTime(lastRead.year, lastRead.month, lastRead.day);
        final today = DateTime(now.year, now.month, now.day);
        final daysSinceLastRead = today.difference(lastDay).inDays;
        debugPrint('STREAK: Days since last read: $daysSinceLastRead');
        
        if (daysSinceLastRead == 0) {
          // Already recorded today
          debugPrint('STREAK: Already recorded today');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reading already recorded today!')),
            );
          }
          return;
        } else if (daysSinceLastRead == 1) {
          // Consecutive day
          newCurrentStreak = currentStreak + 1;
          newLongestStreak = newCurrentStreak > longestStreak ? newCurrentStreak : longestStreak;
          newTotalDays = totalDays + 1;
        } else {
          // Streak broken
          newCurrentStreak = 1;
          newLongestStreak = longestStreak;
          newTotalDays = totalDays + 1;
        }
      }
      
      // Save
      final newStreak = StreakData(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        totalDaysRead: newTotalDays,
        lastReadDate: now,
      );
      debugPrint('STREAK: Saving new streak: $newStreak');
      
      await storage.updateStreak(newStreak);
      debugPrint('STREAK: Saved successfully');
      
      if (mounted) {
        setState(() {
          _streak = newStreak;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newCurrentStreak == 1 
                ? 'Reading recorded! Start your streak!' 
                : 'Reading recorded! $newCurrentStreak day streak! 🔥'),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('STREAK: Error recording: $e');
      debugPrint('STREAK: Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record reading: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentStreak = _streak?.currentStreak ?? 0;
    final longestStreak = _streak?.longestStreak ?? 0;
    final totalDays = _streak?.totalDaysRead ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Streaks'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main streak card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Flame icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        currentStreak > 0 ? '🔥' : '📖',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Current streak
                  Text(
                    '$currentStreak',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentStreak == 1 ? 'Day Streak' : 'Day Streak',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('Longest', '$longestStreak days'),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStat('Total Days', '$totalDays'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Record reading button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _recordReading,
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Today as Read'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Achievements
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildAchievements(currentStreak, totalDays),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(int currentStreak, int totalDays) {
    final achievements = [
      {'icon': '📖', 'title': 'First Steps', 'desc': 'Read your first chapter', 'unlocked': totalDays >= 1},
      {'icon': '🔥', 'title': 'Week Warrior', 'desc': '7-day streak', 'unlocked': currentStreak >= 7},
      {'icon': '⭐', 'title': 'Month Master', 'desc': '30-day streak', 'unlocked': currentStreak >= 30},
      {'icon': '🏆', 'title': 'Century Club', 'desc': '100-day streak', 'unlocked': currentStreak >= 100},
      {'icon': '📚', 'title': 'Dedicated', 'desc': '50 total days', 'unlocked': totalDays >= 50},
      {'icon': '✝️', 'title': 'Faithful', 'desc': '365 total days', 'unlocked': totalDays >= 365},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final unlocked = achievement['unlocked'] as bool;
        
        return Card(
          color: unlocked ? null : Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: unlocked ? 1.0 : 0.3,
                  child: Text(
                    achievement['icon'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement['title'] as String,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
