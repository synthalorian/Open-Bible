import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/providers/app_providers.dart';
import '../../bible/data/models/bible_book.dart';
import '../../bible/data/repositories/bible_repository.dart' show BibleRepository;
import '../../bible/presentation/pages/chapter_reader_page.dart';

/// Search provider
final bibleSearchProvider = StateNotifierProvider<BibleSearchNotifier, BibleSearchState>((ref) {
  return BibleSearchNotifier(ref);
});

/// Recent searches provider
final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<RecentSearch>>((ref) {
  return RecentSearchesNotifier();
});

class RecentSearch {
  final String query;
  final DateTime timestamp;
  final int resultCount;
  
  RecentSearch({
    required this.query,
    required this.timestamp,
    this.resultCount = 0,
  });
  
  Map<String, dynamic> toJson() => {
    'query': query,
    'timestamp': timestamp.toIso8601String(),
    'resultCount': resultCount,
  };
  
  factory RecentSearch.fromJson(Map<String, dynamic> json) => RecentSearch(
    query: json['query'] ?? '',
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    resultCount: json['resultCount'] ?? 0,
  );
}

class RecentSearchesNotifier extends StateNotifier<List<RecentSearch>> {
  static const _maxRecentSearches = 20;
  
  RecentSearchesNotifier() : super([]) {
    _loadRecentSearches();
  }
  
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('recent_searches') ?? [];
      
      final searches = jsonList
          .map((json) {
            try {
              return RecentSearch.fromJson(jsonDecode(json));
            } catch (e) {
              return null;
            }
          })
          .whereType<RecentSearch>()
          .toList();
      
      searches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = searches;
    } catch (_) {}
  }
  
  Future<void> addSearch(String query, {int resultCount = 0}) async {
    if (query.trim().isEmpty) return;
    final newState = state.where((s) => s.query.toLowerCase() != query.toLowerCase()).toList();
    newState.insert(0, RecentSearch(
      query: query,
      timestamp: DateTime.now(),
      resultCount: resultCount,
    ));
    if (newState.length > _maxRecentSearches) {
      newState.removeRange(_maxRecentSearches, newState.length);
    }
    state = newState;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = newState.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList('recent_searches', jsonList);
    } catch (_) {}
  }
  
  Future<void> removeSearch(String query) async {
    final newState = state.where((s) => s.query != query).toList();
    state = newState;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = newState.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList('recent_searches', jsonList);
    } catch (_) {}
  }
  
  Future<void> clearAll() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
    } catch (_) {}
  }
}

class SearchFilter {
  final Set<String> selectedTranslations;
  final Set<String> selectedBooks;
  final bool oldTestamentOnly;
  final bool newTestamentOnly;
  
  const SearchFilter({
    this.selectedTranslations = const {},
    this.selectedBooks = const {},
    this.oldTestamentOnly = false,
    this.newTestamentOnly = false,
  });
  
  SearchFilter copyWith({
    Set<String>? selectedTranslations,
    Set<String>? selectedBooks,
    bool? oldTestamentOnly,
    bool? newTestamentOnly,
  }) {
    return SearchFilter(
      selectedTranslations: selectedTranslations ?? this.selectedTranslations,
      selectedBooks: selectedBooks ?? this.selectedBooks,
      oldTestamentOnly: oldTestamentOnly ?? this.oldTestamentOnly,
      newTestamentOnly: newTestamentOnly ?? this.newTestamentOnly,
    );
  }
  
  bool get hasActiveFilters => 
      selectedTranslations.isNotEmpty ||
      selectedBooks.isNotEmpty ||
      oldTestamentOnly ||
      newTestamentOnly;
}

class SearchResult {
  final String verseId;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String translationId;
  final String translationName;
  final List<TextSpan> highlightedText;
  
  SearchResult({
    required this.verseId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.translationId,
    required this.translationName,
    required this.highlightedText,
  });
}

class BibleSearchState {
  final bool isLoading;
  final String query;
  final List<SearchResult> results;
  final String? error;
  final SearchFilter filter;
  final int totalResults;
  
  const BibleSearchState({
    this.isLoading = false,
    this.query = '',
    this.results = const [],
    this.error,
    this.filter = const SearchFilter(),
    this.totalResults = 0,
  });
  
  BibleSearchState copyWith({
    bool? isLoading,
    String? query,
    List<SearchResult>? results,
    String? error,
    SearchFilter? filter,
    int? totalResults,
    bool clearError = false,
  }) {
    return BibleSearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
      filter: filter ?? this.filter,
      totalResults: totalResults ?? this.totalResults,
    );
  }
}

class BibleSearchNotifier extends StateNotifier<BibleSearchState> {
  final Ref ref;
  Timer? _debounceTimer;
  
  BibleSearchNotifier(this.ref) : super(const BibleSearchState());
  
  void updateQuery(String query) {
    state = state.copyWith(query: query);
    _debounceTimer?.cancel();
    if (query.trim().length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 600), () => search());
    }
  }
  
  Future<void> search() async {
    final query = state.query.trim();
    if (query.length < 2) {
      state = state.copyWith(results: [], totalResults: 0);
      return;
    }
    
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final results = await _performOptimizedSearch(query);
      await ref.read(recentSearchesProvider.notifier).addSearch(query, resultCount: results.length);
      state = state.copyWith(isLoading: false, results: results, totalResults: results.length);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Search failed: $e');
    }
  }
  
  Future<List<SearchResult>> _performOptimizedSearch(String query) async {
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();
    
    final selectedTranslations = state.filter.selectedTranslations.isEmpty
        ? {ref.read(selectedTranslationProvider)}
        : state.filter.selectedTranslations;
    
    for (var translationId in selectedTranslations) {
      if (translationId.isEmpty) translationId = 'kjv';
      try {
        final path = 'assets/bible_data/${translationId.toLowerCase()}_bible.json';
        final jsonString = await rootBundle.loadString(path);
        final Map<String, dynamic> bibleJson = jsonDecode(jsonString);
        final books = bibleJson['books'] as List<dynamic>;
        final transName = bibleJson['name'] ?? translationId.toUpperCase();

        for (final book in books) {
          final bookId = book['id']?.toString() ?? '';
          final bookName = book['name']?.toString() ?? '';
          
          final isOld = _isOldTestament(bookId);
          if (state.filter.oldTestamentOnly && !isOld) continue;
          if (state.filter.newTestamentOnly && isOld) continue;
          if (state.filter.selectedBooks.isNotEmpty && !state.filter.selectedBooks.contains(bookId)) continue;

          final chapters = book['chapters'] as List<dynamic>? ?? [];
          for (final chapter in chapters) {
            final chapterNum = chapter['chapter'] as int? ?? 0;
            final verses = chapter['verses'] as List<dynamic>? ?? [];
            
            for (final verse in verses) {
              final text = verse['text']?.toString() ?? '';
              if (text.toLowerCase().contains(lowerQuery)) {
                results.add(SearchResult(
                  verseId: '$bookId $chapterNum:${verse['verse']}',
                  bookId: bookId,
                  bookName: bookName,
                  chapter: chapterNum,
                  verse: verse['verse'] as int? ?? 0,
                  text: text,
                  translationId: translationId,
                  translationName: transName,
                  highlightedText: _highlightText(text, query),
                ));
              }
              if (results.length >= 200) break;
            }
            if (results.length >= 200) break;
          }
          if (results.length >= 200) break;
        }
      } catch (_) {}
    }
    return results;
  }

  bool _isOldTestament(String bookId) {
    const otIds = ['GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA', '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST', 'JOB', 'PSA', 'PRO', 'ECC', 'SNG', 'ISA', 'JER', 'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO', 'OBA', 'JON', 'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL'];
    return otIds.contains(bookId.toUpperCase());
  }
  
  List<TextSpan> _highlightText(String text, String query) {
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    while (index != -1) {
      if (index > start) spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(TextSpan(text: text.substring(index, index + query.length), style: const TextStyle(backgroundColor: Colors.yellow, fontWeight: FontWeight.bold)));
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return spans;
  }
}

final bibleRepositoryProvider = Provider<BibleRepository>((ref) => BibleRepository());
