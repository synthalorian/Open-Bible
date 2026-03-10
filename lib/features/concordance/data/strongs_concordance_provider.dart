import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Strong's Concordance provider for Greek/Hebrew word lookup
final strongsConcordanceProvider = StateNotifierProvider<StrongsConcordanceNotifier, StrongsConcordanceState>((ref) {
  return StrongsConcordanceNotifier();
});

class StrongsEntry {
  final String number;
  final String word;
  final String transliteration;
  final String pronunciation;
  final String definition;
  final String language; // 'hebrew' or 'greek'
  final List<String> verses;
  final String? extendedDefinition;
  
  StrongsEntry({
    required this.number,
    required this.word,
    required this.transliteration,
    required this.pronunciation,
    required this.definition,
    required this.language,
    this.verses = const [],
    this.extendedDefinition,
  });
  
  factory StrongsEntry.fromJson(Map<String, dynamic> json) => StrongsEntry(
    number: json['number'] ?? '',
    word: json['word'] ?? '',
    transliteration: json['transliteration'] ?? '',
    pronunciation: json['pronunciation'] ?? '',
    definition: json['definition'] ?? '',
    language: json['language'] ?? 'greek',
    verses: List<String>.from(json['verses'] ?? []),
    extendedDefinition: json['extendedDefinition'],
  );
  
  Map<String, dynamic> toJson() => {
    'number': number,
    'word': word,
    'transliteration': transliteration,
    'pronunciation': pronunciation,
    'definition': definition,
    'language': language,
    'verses': verses,
    'extendedDefinition': extendedDefinition,
  };
}

class StrongsConcordanceState {
  final bool isLoading;
  final String? searchTerm;
  final StrongsEntry? currentEntry;
  final List<StrongsEntry> recentSearches;
  final List<StrongsEntry> favorites;
  final String? error;
  
  StrongsConcordanceState({
    this.isLoading = false,
    this.searchTerm,
    this.currentEntry,
    this.recentSearches = const [],
    this.favorites = const [],
    this.error,
  });
  
  StrongsConcordanceState copyWith({
    bool? isLoading,
    String? searchTerm,
    StrongsEntry? currentEntry,
    List<StrongsEntry>? recentSearches,
    List<StrongsEntry>? favorites,
    String? error,
    bool clearError = false,
    bool clearCurrentEntry = false,
  }) {
    return StrongsConcordanceState(
      isLoading: isLoading ?? this.isLoading,
      searchTerm: searchTerm ?? this.searchTerm,
      currentEntry: clearCurrentEntry ? null : (currentEntry ?? this.currentEntry),
      recentSearches: recentSearches ?? this.recentSearches,
      favorites: favorites ?? this.favorites,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StrongsConcordanceNotifier extends StateNotifier<StrongsConcordanceState> {
  final Map<String, StrongsEntry> _strongsData = {};
  bool _isLoaded = false;
  
  StrongsConcordanceNotifier() : super(StrongsConcordanceState()) {
    _loadData();
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final recentJson = prefs.getStringList('strongs_recent') ?? [];
    final favJson = prefs.getStringList('strongs_favorites') ?? [];
    
    final recentSearches = recentJson.map((json) {
      try {
        return StrongsEntry.fromJson(jsonDecode(json));
      } catch (e) {
        return null;
      }
    }).whereType<StrongsEntry>().toList();
    
    final favorites = favJson.map((json) {
      try {
        return StrongsEntry.fromJson(jsonDecode(json));
      } catch (e) {
        return null;
      }
    }).whereType<StrongsEntry>().toList();
    
    state = state.copyWith(
      recentSearches: recentSearches,
      favorites: favorites,
    );
    
    await _loadStrongsData();
  }
  
  Future<void> _loadStrongsData() async {
    if (_isLoaded) return;

    _strongsData.addAll({
      'H1': StrongsEntry(
        number: 'H1',
        word: 'אָב',
        transliteration: 'ab',
        pronunciation: 'awb',
        definition: 'father',
        language: 'hebrew',
        verses: ['Gen 2:24', 'Exo 20:12', 'Deu 5:16'],
        extendedDefinition: 'A primitive word; father, in a literal and immediate, or figurative and remote application)',
      ),
      'H2': StrongsEntry(
        number: 'H2',
        word: 'אָבָה',
        transliteration: 'abah',
        pronunciation: 'aw-baw',
        definition: 'to consent, agree, yield',
        language: 'hebrew',
        verses: ['Exo 10:24', 'Job 21:14', 'Psa 81:11'],
      ),
      'H430': StrongsEntry(
        number: 'H430',
        word: 'אֱלֹהִים',
        transliteration: 'Elohim',
        pronunciation: 'el-o-heem',
        definition: 'God, gods, deity',
        language: 'hebrew',
        verses: ['Gen 1:1', 'Gen 1:2', 'Gen 1:3'],
        extendedDefinition: 'Plural of H433; gods in the ordinary sense; but specifically used of the supreme God',
      ),
      'G1': StrongsEntry(
        number: 'G1',
        word: 'Ἀββᾶ',
        transliteration: 'Abba',
        pronunciation: 'ab-bah',
        definition: 'father',
        language: 'greek',
        verses: ['Mar 14:36', 'Rom 8:15', 'Gal 4:6'],
        extendedDefinition: 'Of Chaldee origin; father as a vocative',
      ),
      'G26': StrongsEntry(
        number: 'G26',
        word: 'ἀγαπάω',
        transliteration: 'agapao',
        pronunciation: 'ag-ap-ah-o',
        definition: 'to love',
        language: 'greek',
        verses: ['Mat 5:43', 'Mat 5:44', 'Mat 5:46'],
        extendedDefinition: 'Perhaps from agan (much); to love (in a social or moral sense)',
      ),
      'G3056': StrongsEntry(
        number: 'G3056',
        word: 'λόγος',
        transliteration: 'logos',
        pronunciation: 'log-os',
        definition: 'word, saying, message',
        language: 'greek',
        verses: ['Joh 1:1', 'Joh 1:14', 'Act 10:36'],
        extendedDefinition: 'From G3004; something said (including the thought); by implication a topic',
      ),
    });

    _isLoaded = true;
  }

  String _normalizeNumber(String input) {
    final trimmed = input.trim().toUpperCase();
    final match = RegExp(r'^([HG])(\d+)$').firstMatch(trimmed);
    if (match == null) return trimmed;

    final prefix = match.group(1)!;
    final num = int.tryParse(match.group(2) ?? '0') ?? 0;

    final four = '$prefix${num.toString().padLeft(4, '0')}';
    if (_strongsData.containsKey(four)) return four;

    final plain = '$prefix$num';
    if (_strongsData.containsKey(plain)) return plain;

    return trimmed;
  }
  
  Future<void> lookupWord(String strongsNumber) async {
    if (!_isLoaded) {
      await _loadStrongsData();
    }

    final normalizedNumber = _normalizeNumber(strongsNumber);
    
    state = state.copyWith(isLoading: true, searchTerm: strongsNumber, error: null);
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    final entry = _strongsData[normalizedNumber];
    
    if (entry != null) {
      final recentSearches = [entry, ...state.recentSearches.where((e) => e.number != entry.number)];
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
      
      state = state.copyWith(
        isLoading: false,
        currentEntry: entry,
        recentSearches: recentSearches,
      );
      
      await _saveRecentSearches(recentSearches);
    } else {
      state = state.copyWith(
        isLoading: false,
        currentEntry: null,
        error: 'Strong\'s number "$strongsNumber" not found',
      );
    }
  }
  
  Future<void> searchByWord(String word) async {
    if (!_isLoaded) {
      await _loadStrongsData();
    }

    state = state.copyWith(isLoading: true, searchTerm: word, error: null);
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    final lowerWord = word.toLowerCase();
    final matches = _strongsData.values.where((entry) =>
      entry.transliteration.toLowerCase().contains(lowerWord) ||
      entry.word.contains(word) ||
      entry.definition.toLowerCase().contains(lowerWord)
    ).toList();
    
    if (matches.isNotEmpty) {
      state = state.copyWith(
        isLoading: false,
        currentEntry: matches.first,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        currentEntry: null,
        error: 'No entries found for "$word"',
      );
    }
  }
  
  Future<void> toggleFavorite(StrongsEntry entry) async {
    final isFav = state.favorites.any((f) => f.number == entry.number);
    
    List<StrongsEntry> newFavorites;
    if (isFav) {
      newFavorites = state.favorites.where((f) => f.number != entry.number).toList();
    } else {
      newFavorites = [...state.favorites, entry];
    }
    
    state = state.copyWith(favorites: newFavorites);
    await _saveFavorites(newFavorites);
  }
  
  bool isFavorite(String strongsNumber) {
    return state.favorites.any((f) => f.number == strongsNumber);
  }
  
  Future<void> _saveRecentSearches(List<StrongsEntry> searches) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = searches.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('strongs_recent', jsonList);
  }
  
  Future<void> _saveFavorites(List<StrongsEntry> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('strongs_favorites', jsonList);
  }
  
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSelection() {
    state = state.copyWith(clearCurrentEntry: true, clearError: true);
  }
}
