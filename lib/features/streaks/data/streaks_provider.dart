import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading streaks provider for tracking daily Bible reading
final readingStreaksProvider = StateNotifierProvider<ReadingStreaksNotifier, ReadingStreaksState>((ref) {
  return ReadingStreaksNotifier();
});

class ReadingStreaksState {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;
  final int totalDaysRead;
  final List<DateTime> readDates;
  
  ReadingStreaksState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReadDate,
    this.totalDaysRead = 0,
    this.readDates = const [],
  });
  
  ReadingStreaksState copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    int? totalDaysRead,
    List<DateTime>? readDates,
  }) {
    return ReadingStreaksState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      totalDaysRead: totalDaysRead ?? this.totalDaysRead,
      readDates: readDates ?? this.readDates,
    );
  }
  
  bool get hasReadToday {
    if (lastReadDate == null) return false;
    final now = DateTime.now();
    return lastReadDate!.year == now.year &&
           lastReadDate!.month == now.month &&
           lastReadDate!.day == now.day;
  }
  
  int get daysThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return readDates.where((date) => 
      date.isAfter(weekStart.subtract(const Duration(days: 1))) ||
      (date.year == weekStart.year && date.month == weekStart.month && date.day == weekStart.day)
    ).length;
  }
}

class ReadingStreaksNotifier extends StateNotifier<ReadingStreaksState> {
  ReadingStreaksNotifier() : super(ReadingStreaksState()) {
    _loadStreaks();
  }
  
  Future<void> _loadStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    final currentStreak = prefs.getInt('current_streak') ?? 0;
    final longestStreak = prefs.getInt('longest_streak') ?? 0;
    final totalDaysRead = prefs.getInt('total_days_read') ?? 0;
    final lastReadStr = prefs.getString('last_read_date');
    final readDatesStr = prefs.getStringList('read_dates') ?? [];
    
    final lastReadDate = lastReadStr != null ? DateTime.tryParse(lastReadStr) : null;
    final readDates = readDatesStr.map((s) => DateTime.tryParse(s)).whereType<DateTime>().toList();
    
    state = ReadingStreaksState(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastReadDate: lastReadDate,
      totalDaysRead: totalDaysRead,
      readDates: readDates,
    );
    
    // Check if streak should be reset (missed a day)
    _checkStreakReset();
  }
  
  void _checkStreakReset() {
    if (state.lastReadDate == null) return;
    
    final now = DateTime.now();
    final lastRead = state.lastReadDate!;
    final difference = now.difference(lastRead).inDays;
    
    // If more than 1 day has passed, reset streak
    if (difference > 1) {
      state = state.copyWith(currentStreak: 0);
      _saveStreaks();
    }
  }
  
  Future<void> recordReading() async {
    final now = DateTime.now();
    
    // Already recorded today
    if (state.hasReadToday) return;
    
    final newTotalDays = state.totalDaysRead + 1;
    var newCurrentStreak = state.currentStreak + 1;
    var newLongestStreak = state.longestStreak;
    
    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }
    
    // Add today to read dates
    final today = DateTime(now.year, now.month, now.day);
    final newReadDates = [...state.readDates, today];
    
    // Keep only last 365 days
    if (newReadDates.length > 365) {
      newReadDates.removeAt(0);
    }
    
    state = state.copyWith(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastReadDate: now,
      totalDaysRead: newTotalDays,
      readDates: newReadDates,
    );
    
    await _saveStreaks();
  }
  
  Future<void> _saveStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_streak', state.currentStreak);
    await prefs.setInt('longest_streak', state.longestStreak);
    await prefs.setInt('total_days_read', state.totalDaysRead);
    if (state.lastReadDate != null) {
      await prefs.setString('last_read_date', state.lastReadDate!.toIso8601String());
    }
    await prefs.setStringList(
      'read_dates',
      state.readDates.map((d) => d.toIso8601String()).toList(),
    );
  }
  
  Future<void> resetStreaks() async {
    state = ReadingStreaksState();
    await _saveStreaks();
  }
}
