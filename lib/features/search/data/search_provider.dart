import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
    timestamp: DateTime.parse(json['timestamp']),
    resultCount: json['resultCount'] ?? 0,
  );
}

class RecentSearchesNotifier extends StateNotifier<List<RecentSearch>> {
  static const _maxRecentSearches = 20;
  
  RecentSearchesNotifier() : super([]) {
    _loadRecentSearches();
  }
  
  Future<void> _loadRecentSearches() async {
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
    
    // Sort by timestamp, newest first
    searches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    state = searches;
  }
  
  Future<void> addSearch(String query, {int resultCount = 0}) async {
    if (query.trim().isEmpty) return;
    
    // Remove duplicate if exists
    final newState = state.where((s) => s.query.toLowerCase() != query.toLowerCase()).toList();
    
    // Add new search at the beginning
    newState.insert(0, RecentSearch(
      query: query,
      timestamp: DateTime.now(),
      resultCount: resultCount,
    ));
    
    // Keep only max recent searches
    if (newState.length > _maxRecentSearches) {
      newState.removeRange(_maxRecentSearches, newState.length);
    }
    
    state = newState;
    
    // Save to prefs
    final prefs = await SharedPreferences.getInstance();
    final jsonList = newState.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('recent_searches', jsonList);
  }
  
  Future<void> removeSearch(String query) async {
    final newState = state.where((s) => s.query != query).toList();
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = newState.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('recent_searches', jsonList);
  }
  
  Future<void> clearAll() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
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
  final int currentPage;
  final bool hasMoreResults;
  
  const BibleSearchState({
    this.isLoading = false,
    this.query = '',
    this.results = const [],
    this.error,
    this.filter = const SearchFilter(),
    this.totalResults = 0,
    this.currentPage = 0,
    this.hasMoreResults = false,
  });
  
  BibleSearchState copyWith({
    bool? isLoading,
    String? query,
    List<SearchResult>? results,
    String? error,
    SearchFilter? filter,
    int? totalResults,
    int? currentPage,
    bool? hasMoreResults,
    bool clearError = false,
  }) {
    return BibleSearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
      filter: filter ?? this.filter,
      totalResults: totalResults ?? this.totalResults,
      currentPage: currentPage ?? this.currentPage,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
    );
  }
}

class BibleSearchNotifier extends StateNotifier<BibleSearchState> {
  final Ref ref;
  Timer? _debounceTimer;
  
  BibleSearchNotifier(this.ref) : super(const BibleSearchState());
  
  void updateQuery(String query) {
    state = state.copyWith(query: query);
    
    // Debounce search
    _debounceTimer?.cancel();
    if (query.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        search();
      });
    }
  }
  
  Future<void> search() async {
    final query = state.query.trim();
    if (query.isEmpty) {
      state = state.copyWith(results: [], totalResults: 0);
      return;
    }
    
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final repository = ref.read(bibleRepositoryProvider);
      final results = await _performSearch(repository, query);
      
      // Add to recent searches
      await ref.read(recentSearchesProvider.notifier).addSearch(query, resultCount: results.length);
      
      state = state.copyWith(
        isLoading: false,
        results: results,
        totalResults: results.length,
        hasMoreResults: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }
  
  Future<List<SearchResult>> _performSearch(BibleRepository repository, String query) async {
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();
    
    // Get selected translations or all available
    final allTranslations = availableTranslations;
    final selectedTranslations = state.filter.selectedTranslations.isEmpty
        ? allTranslations.map((t) => t.id).toSet()
        : state.filter.selectedTranslations;
    
    // Get all books
    final allBooks = await repository.getBooks();
    
    // Filter books by testament if specified
    var booksToSearch = allBooks;
    if (state.filter.oldTestamentOnly) {
      booksToSearch = allBooks.where((b) => b.testament == Testament.old).toList();
    } else if (state.filter.newTestamentOnly) {
      booksToSearch = allBooks.where((b) => b.testament == Testament.newTestament).toList();
    }
    
    // Filter by selected books
    if (state.filter.selectedBooks.isNotEmpty) {
      booksToSearch = booksToSearch.where((b) => state.filter.selectedBooks.contains(b.id)).toList();
    }
    
    // Search through each translation
    for (final translationId in selectedTranslations) {
      try {
        final translationBooks = await repository.getBooks(translationId);
        
        for (final book in booksToSearch) {
          final translationBook = translationBooks.firstWhere(
            (b) => b.id == book.id,
            orElse: () => book,
          );
          
          // Search through chapters
          for (int chapter = 1; chapter <= translationBook.chapters; chapter++) {
            try {
              final chapterData = await repository.getChapter(translationId, book.id, chapter);
              
              if (chapterData != null) {
                // Parse verses from chapter content
                final verses = _parseVerses(chapterData.content);
                
                for (final verse in verses) {
                  if (verse['text'].toString().toLowerCase().contains(lowerQuery)) {
                    results.add(SearchResult(
                      verseId: '${book.id} $chapter:${verse['verse']}',
                      bookId: book.id,
                      bookName: book.name,
                      chapter: chapter,
                      verse: verse['verse'] as int,
                      text: verse['text'],
                      translationId: translationId,
                      translationName: _getTranslationName(translationId),
                      highlightedText: _highlightText(verse['text'], query),
                    ));
                  }
                }
              }
            } catch (e) {
              // Skip chapters that fail to load
              continue;
            }
          }
        }
      } catch (e) {
        // Skip translations that fail to load
        continue;
      }
    }
    
    // Sort results by relevance (exact matches first)
    results.sort((a, b) {
      final aExact = a.text.toLowerCase().contains(' $lowerQuery ') || 
                     a.text.toLowerCase().startsWith('$lowerQuery ');
      final bExact = b.text.toLowerCase().contains(' $lowerQuery ') || 
                     b.text.toLowerCase().startsWith('$lowerQuery ');
      
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      return 0;
    });
    
    return results;
  }
  
  List<Map<String, dynamic>> _parseVerses(String content) {
    final verses = <Map<String, dynamic>>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      final match = RegExp(r'^(\d+)\s+(.+)$').firstMatch(line.trim());
      if (match != null) {
        verses.add({
          'verse': int.parse(match.group(1)!),
          'text': match.group(2)!,
        });
      }
    }
    
    return verses;
  }
  
  List<TextSpan> _highlightText(String text, String query) {
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    
    return spans;
  }
  
  String _getTranslationName(String translationId) {
    final translations = availableTranslations;
    final translation = translations.firstWhere(
      (t) => t.id == translationId,
      orElse: () => const BibleTranslation(id: '', name: 'Unknown', abbreviation: '', language: ''),
    );
    return translation.name;
  }
  
  void updateFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
    search();
  }
  
  void clearResults() {
    state = const BibleSearchState();
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Bible repository provider
final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
});
