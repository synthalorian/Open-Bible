import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/utils/logger.dart';

/// Devotional provider for daily devotional content
final devotionalProvider = StateNotifierProvider<DevotionalNotifier, DevotionalState>((ref) {
  return DevotionalNotifier();
});

class DevotionalEntry {
  final String id;
  final String title;
  final String scripture;
  final String content;
  final String verseReference;
  final String? author;
  final List<String> tags;
  final String? prayerPrompt;
  final DateTime? date;
  
  DevotionalEntry({
    required this.id,
    required this.title,
    required this.scripture,
    required this.content,
    required this.verseReference,
    this.author,
    this.tags = const [],
    this.prayerPrompt,
    this.date,
  });
  
  factory DevotionalEntry.fromJson(Map<String, dynamic> json) => DevotionalEntry(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    scripture: json['scripture'] ?? '',
    content: json['content'] ?? '',
    verseReference: json['verseReference'] ?? '',
    author: json['author'],
    tags: List<String>.from(json['tags'] ?? []),
    prayerPrompt: json['prayerPrompt'],
    date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'scripture': scripture,
    'content': content,
    'verseReference': verseReference,
    'author': author,
    'tags': tags,
    'prayerPrompt': prayerPrompt,
    'date': date?.toIso8601String(),
  };
}

class DevotionalState {
  final bool isLoading;
  final DevotionalEntry? todayDevotional;
  final List<DevotionalEntry> recentDevotionals;
  final List<DevotionalEntry> savedDevotionals;
  final String? error;
  
  DevotionalState({
    this.isLoading = false,
    this.todayDevotional,
    this.recentDevotionals = const [],
    this.savedDevotionals = const [],
    this.error,
  });
  
  DevotionalState copyWith({
    bool? isLoading,
    DevotionalEntry? todayDevotional,
    List<DevotionalEntry>? recentDevotionals,
    List<DevotionalEntry>? savedDevotionals,
    String? error,
    bool clearError = false,
  }) {
    return DevotionalState(
      isLoading: isLoading ?? this.isLoading,
      todayDevotional: todayDevotional ?? this.todayDevotional,
      recentDevotionals: recentDevotionals ?? this.recentDevotionals,
      savedDevotionals: savedDevotionals ?? this.savedDevotionals,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DevotionalNotifier extends StateNotifier<DevotionalState> {
  DevotionalNotifier() : super(DevotionalState()) {
    _loadData();
  }
  
  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getStringList('devotionals_saved') ?? [];
    final recentJson = prefs.getStringList('devotionals_recent') ?? [];
    
    final savedDevotionals = savedJson
        .map((json) {
          try {
            return DevotionalEntry.fromJson(jsonDecode(json));
          } catch (e) {
            logDebug('Failed to parse saved devotional entry: $e');
            return null;
          }
        })
        .whereType<DevotionalEntry>()
        .toList();

    final recentDevotionals = recentJson
        .map((json) {
          try {
            return DevotionalEntry.fromJson(jsonDecode(json));
          } catch (e) {
            logDebug('Failed to parse recent devotional entry: $e');
            return null;
          }
        })
        .whereType<DevotionalEntry>()
        .toList();
    
    // Load today's devotional
    final todayDevotional = _getTodaysDevotional();
    
    state = state.copyWith(
      isLoading: false,
      todayDevotional: todayDevotional,
      savedDevotionals: savedDevotionals,
      recentDevotionals: recentDevotionals,
    );
  }
  
  DevotionalEntry _getTodaysDevotional() {
    // Sample devotionals - in production, load from assets
    final devotionals = [
      DevotionalEntry(
        id: '1',
        title: 'Trust in the Lord',
        scripture: 'Proverbs 3:5-6',
        content: 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
        verseReference: 'Proverbs 3:5-6',
        author: 'Charles Spurgeon',
        tags: const ['faith', 'trust', 'guidance'],
        prayerPrompt: 'Lord, help me trust You completely today.',
        date: DateTime.now(),
      ),
      DevotionalEntry(
        id: '2',
        title: 'The Peace of God',
        scripture: 'Philippians 4:6-7',
        content: 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.',
        verseReference: 'Philippians 4:6-7',
        author: 'John Wesley',
        tags: const ['peace', 'prayer', 'thanksgiving'],
        prayerPrompt: 'Father, I cast my cares upon You.',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DevotionalEntry(
        id: '3',
        title: 'Walk by Faith',
        scripture: '2 Corinthians 5:7',
        content: 'For we live by faith, not by sight.',
        verseReference: '2 Corinthians 5:7',
        author: 'Dwight Moody',
        tags: const ['faith', 'walk'],
        prayerPrompt: 'Help me walk by faith, not by sight.',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    
    // Return devotional based on day of year
    final dayOfYear = DateTime.now().day % devotionals.length;
    return devotionals[dayOfYear];
  }
  
  Future<void> saveDevotional(DevotionalEntry entry) async {
    if (state.savedDevotionals.any((d) => d.id == entry.id)) return;
    
    final newSaved = [...state.savedDevotionals, entry];
    state = state.copyWith(savedDevotionals: newSaved);
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = newSaved.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('devotionals_saved', jsonList);
  }
  
  Future<void> unsaveDevotional(String id) async {
    final newSaved = state.savedDevotionals.where((d) => d.id != id).toList();
    state = state.copyWith(savedDevotionals: newSaved);
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = newSaved.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('devotionals_saved', jsonList);
  }
  
  bool isSaved(String id) {
    return state.savedDevotionals.any((d) => d.id == id);
  }
  
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
