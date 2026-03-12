import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../features/bible/domain/bible_models.dart';

/// Bible API service using api.bible
class BibleApiService {
  final Dio _dio;
  
  BibleApiService({String? apiKey}) : _dio = Dio(BaseOptions(
    baseUrl: AppConstants.bibleApiBaseUrl,
    headers: {
      'api-key': apiKey ?? '',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: false, // never log headers (contains API key)
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  /// Get all available Bible translations
  Future<List<BibleTranslation>> getBibles({String? language}) async {
    try {
      final response = await _dio.get('/bibles', queryParameters: {
        if (language != null) 'language': language,
      });
      
      final data = response.data['data'] as List;
      return data.map((json) => BibleTranslation.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific Bible translation
  Future<BibleTranslation> getBible(String bibleId) async {
    try {
      final response = await _dio.get('/bibles/$bibleId');
      return BibleTranslation.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all books of a Bible
  Future<List<BibleBook>> getBooks(String bibleId) async {
    try {
      final response = await _dio.get('/bibles/$bibleId/books');
      final data = response.data['data'] as List;
      return data.map((json) => BibleBook.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific book
  Future<BibleBook> getBook(String bibleId, String bookId) async {
    try {
      final response = await _dio.get('/bibles/$bibleId/books/$bookId');
      return BibleBook.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a chapter with its verses
  Future<ChapterContent> getChapter(
    String bibleId,
    String chapterId, {
    bool includeNotes = false,
  }) async {
    try {
      final response = await _dio.get(
        '/bibles/$bibleId/chapters/$chapterId',
        queryParameters: {
          'content-type': 'text',
          'include-notes': includeNotes,
          'include-titles': true,
          'include-chapter-numbers': true,
          'include-verse-numbers': true,
        },
      );
      return ChapterContent.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific verse
  Future<Verse> getVerse(String bibleId, String verseId) async {
    try {
      final response = await _dio.get(
        '/bibles/$bibleId/verses/$verseId',
        queryParameters: {'content-type': 'text'},
      );
      return Verse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search the Bible
  Future<SearchResults> search(
    String bibleId,
    String query, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/bibles/$bibleId/search',
        queryParameters: {
          'query': query,
          'limit': limit,
          'offset': offset,
          'sort': 'relevance',
        },
      );
      return SearchResults.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get sections (for cross-references)
  Future<List<Section>> getSections(String bibleId, String bookId) async {
    try {
      final response = await _dio.get('/bibles/$bibleId/books/$bookId/sections');
      final data = response.data['data'] as List;
      return data.map((json) => Section.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get passage (multiple verses/sections)
  Future<PassageContent> getPassage(
    String bibleId,
    String passageId, {
    bool includeVerseNumbers = true,
  }) async {
    try {
      final response = await _dio.get(
        '/bibles/$bibleId/passages/$passageId',
        queryParameters: {
          'content-type': 'text',
          'include-verse-numbers': includeVerseNumbers,
          'include-titles': true,
        },
      );
      return PassageContent.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return BibleApiException('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return BibleApiException('Invalid API key.');
        } else if (statusCode == 403) {
          return BibleApiException('Access forbidden. Please check your subscription.');
        } else if (statusCode == 404) {
          return BibleApiException('Resource not found.');
        } else if (statusCode == 429) {
          return BibleApiException('Rate limit exceeded. Please try again later.');
        }
        return BibleApiException('Server error: $statusCode');
      case DioExceptionType.cancel:
        return BibleApiException('Request cancelled.');
      default:
        return BibleApiException('An unexpected error occurred: ${e.message}');
    }
  }
}

/// Chapter content with verses
class ChapterContent {
  final String id;
  final String bibleId;
  final String bookId;
  final int number;
  final String content;
  final String reference;
  final int verseCount;
  final List<Verse> verses;

  const ChapterContent({
    required this.id,
    required this.bibleId,
    required this.bookId,
    required this.number,
    required this.content,
    required this.reference,
    required this.verseCount,
    required this.verses,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    // TODO(M12): Parse individual verses from content string.
    // The API returns plain text — splitting by verse numbers or HTML tags
    // would require format-specific parsing. For now verses list stays empty
    // and callers should use the raw `content` field.
    final verses = <Verse>[];
    final content = json['content'] ?? '';
    
    return ChapterContent(
      id: json['id'] ?? '',
      bibleId: json['bibleId'] ?? '',
      bookId: json['bookId'] ?? '',
      number: json['number'] ?? 1,
      content: content,
      reference: json['reference'] ?? '',
      verseCount: json['verseCount'] ?? 0,
      verses: verses,
    );
  }
}

/// Search results
class SearchResults {
  final int total;
  final int returned;
  final List<SearchResultVerse> verses;

  const SearchResults({
    required this.total,
    required this.returned,
    required this.verses,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final verses = (json['verses'] as List?)
        ?.map((v) => SearchResultVerse.fromJson(v))
        .toList() ?? [];
    
    return SearchResults(
      total: json['total'] ?? 0,
      returned: json['returned'] ?? 0,
      verses: verses,
    );
  }
}

/// Search result verse
class SearchResultVerse {
  final String id;
  final String bibleId;
  final String bookId;
  final String chapterId;
  final String text;
  final String reference;
  final int? verseCount;

  const SearchResultVerse({
    required this.id,
    required this.bibleId,
    required this.bookId,
    required this.chapterId,
    required this.text,
    required this.reference,
    this.verseCount,
  });

  factory SearchResultVerse.fromJson(Map<String, dynamic> json) {
    return SearchResultVerse(
      id: json['id'] ?? '',
      bibleId: json['bibleId'] ?? '',
      bookId: json['bookId'] ?? '',
      chapterId: json['chapterId'] ?? '',
      text: json['text'] ?? '',
      reference: json['reference'] ?? '',
      verseCount: json['verseCount'],
    );
  }
}

/// Section for cross-references
class Section {
  final String id;
  final String bibleId;
  final String bookId;
  final String title;
  final String content;

  const Section({
    required this.id,
    required this.bibleId,
    required this.bookId,
    required this.title,
    required this.content,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? '',
      bibleId: json['bibleId'] ?? '',
      bookId: json['bookId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// Passage content
class PassageContent {
  final String id;
  final String bibleId;
  final String content;
  final String reference;
  final List<Verse> verses;

  const PassageContent({
    required this.id,
    required this.bibleId,
    required this.content,
    required this.reference,
    required this.verses,
  });

  factory PassageContent.fromJson(Map<String, dynamic> json) {
    return PassageContent(
      id: json['id'] ?? '',
      bibleId: json['bibleId'] ?? '',
      content: json['content'] ?? '',
      reference: json['reference'] ?? '',
      verses: [],
    );
  }
}

/// Custom exception for Bible API errors
class BibleApiException implements Exception {
  final String message;
  BibleApiException(this.message);
  
  @override
  String toString() => message;
}

/// Provider for Bible API service
final bibleApiServiceProvider = Provider<BibleApiService>((ref) {
  return BibleApiService();
});
