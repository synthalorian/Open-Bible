import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../bible/data/repositories/bible_repository.dart' show BibleRepository;

/// Verse comparison provider
final verseComparisonProvider = StateNotifierProvider<VerseComparisonNotifier, VerseComparisonState>((ref) {
  return VerseComparisonNotifier(ref);
});

class VerseComparisonState {
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String verseText;
  final bool isLoading;
  final List<TranslationComparison> comparisons;
  final Set<String> selectedTranslations;
  final String? error;

  VerseComparisonState({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    this.verseText = '',
    this.isLoading = false,
    this.comparisons = const [],
    Set<String>? selectedTranslations,
    this.error,
  }) : selectedTranslations = selectedTranslations ?? {};

  VerseComparisonState copyWith({
    String? bookId,
    String? bookName,
    int? chapter,
    int? verse,
    String? verseText,
    bool? isLoading,
    List<TranslationComparison>? comparisons,
    Set<String>? selectedTranslations,
    String? error,
    bool clearError = false,
  }) {
    return VerseComparisonState(
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      verseText: verseText ?? this.verseText,
      isLoading: isLoading ?? this.isLoading,
      comparisons: comparisons ?? this.comparisons,
      selectedTranslations: selectedTranslations ?? this.selectedTranslations,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TranslationComparison {
  final String translationId;
  final String translationName;
  final String translationAbbreviation;
  final String text;
  final bool isPrimary;

  TranslationComparison({
    required this.translationId,
    required this.translationName,
    required this.translationAbbreviation,
    required this.text,
    this.isPrimary = false,
  });
}

class VerseComparisonNotifier extends StateNotifier<VerseComparisonState> {
  final Ref ref;

  VerseComparisonNotifier(this.ref) 
      : super(VerseComparisonState(
          bookId: 'GEN',
          bookName: 'Genesis',
          chapter: 1,
          verse: 1,
          selectedTranslations: {'kjv', 'asv', 'web'},
        ));

  void setVerse(String bookId, String bookName, int chapter, int verse, String verseText) {
    state = state.copyWith(
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      verseText: verseText,
      comparisons: [],
      clearError: true,
    );
    loadComparisons();
  }

  Future<void> loadComparisons() async {
    if (state.selectedTranslations.isEmpty) {
      state = state.copyWith(comparisons: []);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = BibleRepository();
      final comparisons = <TranslationComparison>[];

      for (final translationId in state.selectedTranslations) {
        try {
          final text = await _loadVerseText(repository, translationId);
          if (text != null) {
            comparisons.add(TranslationComparison(
              translationId: translationId,
              translationName: _getTranslationName(translationId),
              translationAbbreviation: translationId.toUpperCase(),
              text: text,
              isPrimary: translationId == 'kjv',
            ));
          }
        } catch (e) {
          // Skip translations that fail to load
          continue;
        }
      }

      // Sort: primary first, then alphabetically
      comparisons.sort((a, b) {
        if (a.isPrimary) return -1;
        if (b.isPrimary) return 1;
        return a.translationName.compareTo(b.translationName);
      });

      state = state.copyWith(
        isLoading: false,
        comparisons: comparisons,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load comparisons: $e',
      );
    }
  }

  Future<String?> _loadVerseText(BibleRepository repository, String translationId) async {
    try {
      final chapterData = await repository.getChapter(translationId, state.bookId, state.chapter);
      if (chapterData == null) return null;

      // Parse verses from chapter content
      final verses = _parseVerses(chapterData.content);
      
      // Find the specific verse
      for (final v in verses) {
        if (v['verse'] == state.verse) {
          return v['text'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
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

  String _getTranslationName(String translationId) {
    final translations = availableTranslations;
    final translation = translations.firstWhere(
      (t) => t.id == translationId,
      orElse: () => const BibleTranslation(
        id: '',
        name: 'Unknown',
        abbreviation: '',
        language: '',
      ),
    );
    return translation.name;
  }

  void toggleTranslation(String translationId) {
    final newSet = Set<String>.from(state.selectedTranslations);
    if (newSet.contains(translationId)) {
      if (newSet.length > 1) {
        newSet.remove(translationId);
      }
    } else {
      newSet.add(translationId);
    }
    state = state.copyWith(selectedTranslations: newSet);
    loadComparisons();
  }

  void setSelectedTranslations(Set<String> translations) {
    state = state.copyWith(selectedTranslations: translations);
    loadComparisons();
  }
}

/// Extension method for Riverpod ref
extension RefListenManual on Ref {
  void listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener,
  ) {
    listen<T>(provider, listener, fireImmediately: false);
  }
}
