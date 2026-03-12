import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Prayer journal provider for tracking prayers
final prayerJournalProvider = StateNotifierProvider<PrayerJournalNotifier, PrayerJournalState>((ref) {
  return PrayerJournalNotifier();
});

class PrayerEntry {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final bool isAnswered;
  final List<String> tags;
  final String? notes;
  
  PrayerEntry({
    required this.id,
    required this.text,
    required this.createdAt,
    this.answeredAt,
    this.isAnswered = false,
    this.tags = const [],
    this.notes,
  });
  
  factory PrayerEntry.fromJson(Map<String, dynamic> json) => PrayerEntry(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt']) : null,
    isAnswered: json['isAnswered'] ?? false,
    tags: List<String>.from(json['tags'] ?? []),
    notes: json['notes'],
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'answeredAt': answeredAt?.toIso8601String(),
    'isAnswered': isAnswered,
    'tags': tags,
    'notes': notes,
  };
  
  PrayerEntry copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    DateTime? answeredAt,
    bool? isAnswered,
    List<String>? tags,
    String? notes,
  }) {
    return PrayerEntry(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      isAnswered: isAnswered ?? this.isAnswered,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }
}

class PrayerJournalState {
  final List<PrayerEntry> prayers;
  final List<String> allTags;
  
  PrayerJournalState({
    this.prayers = const [],
    this.allTags = const [],
  });
  
  PrayerJournalState copyWith({
    List<PrayerEntry>? prayers,
    List<String>? allTags,
  }) {
    return PrayerJournalState(
      prayers: prayers ?? this.prayers,
      allTags: allTags ?? this.allTags,
    );
  }
  
  List<PrayerEntry> get activePrayers => prayers.where((p) => !p.isAnswered).toList();
  List<PrayerEntry> get answeredPrayers => prayers.where((p) => p.isAnswered).toList();
  
  int get totalPrayers => prayers.length;
  int get totalAnswered => answeredPrayers.length;
  int get totalActive => activePrayers.length;
}

class PrayerJournalNotifier extends StateNotifier<PrayerJournalState> {
  PrayerJournalNotifier() : super(PrayerJournalState()) {
    _loadPrayers();
  }
  
  Future<void> _loadPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final prayersJson = prefs.getStringList('prayers') ?? [];
    
    final prayers = prayersJson.map((json) {
      try {
        return PrayerEntry.fromJson(jsonDecode(json));
      } catch (e) {
        debugPrint('Failed to parse prayer entry: $e');
        return null;
      }
    }).whereType<PrayerEntry>().toList();
    
    // Extract all unique tags
    final allTags = <String>{};
    for (final prayer in prayers) {
      allTags.addAll(prayer.tags);
    }
    
    state = state.copyWith(
      prayers: prayers,
      allTags: allTags.toList()..sort(),
    );
  }
  
  Future<void> addPrayer(String text, {List<String>? tags}) async {
    final prayer = PrayerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now(),
      tags: tags ?? [],
    );
    
    final newPrayers = [...state.prayers, prayer];
    final newTags = {...state.allTags, ...?tags}.toList()..sort();
    
    state = state.copyWith(prayers: newPrayers, allTags: newTags);
    await _savePrayers();
  }
  
  Future<void> markAsAnswered(String prayerId, {String? notes}) async {
    final prayers = state.prayers.map((p) {
      if (p.id == prayerId) {
        return p.copyWith(
          isAnswered: true,
          answeredAt: DateTime.now(),
          notes: notes ?? p.notes,
        );
      }
      return p;
    }).toList();
    
    state = state.copyWith(prayers: prayers);
    await _savePrayers();
  }
  
  Future<void> updatePrayer(PrayerEntry updatedPrayer) async {
    final prayers = state.prayers.map((p) {
      return p.id == updatedPrayer.id ? updatedPrayer : p;
    }).toList();
    
    // Update tags
    final allTags = <String>{};
    for (final prayer in prayers) {
      allTags.addAll(prayer.tags);
    }
    
    state = state.copyWith(prayers: prayers, allTags: allTags.toList()..sort());
    await _savePrayers();
  }
  
  Future<void> deletePrayer(String prayerId) async {
    final prayers = state.prayers.where((p) => p.id != prayerId).toList();
    
    // Recalculate tags
    final allTags = <String>{};
    for (final prayer in prayers) {
      allTags.addAll(prayer.tags);
    }
    
    state = state.copyWith(prayers: prayers, allTags: allTags.toList()..sort());
    await _savePrayers();
  }
  
  Future<void> _savePrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final prayersJson = state.prayers.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('prayers', prayersJson);
  }
  
  List<PrayerEntry> getPrayersByTag(String tag) {
    return state.prayers.where((p) => p.tags.contains(tag)).toList();
  }
  
  List<PrayerEntry> searchPrayers(String query) {
    final lowerQuery = query.toLowerCase();
    return state.prayers.where((p) => 
      p.text.toLowerCase().contains(lowerQuery) ||
      p.tags.any((t) => t.toLowerCase().contains(lowerQuery))
    ).toList();
  }
}
