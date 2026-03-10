import 'package:shared_preferences/shared_preferences.dart';

/// Service to track and restore reading progress using SharedPreferences
class ContinueReadingService {
  static const String _keyBookId = 'last_book_id';
  static const String _keyBookName = 'last_book_name';
  static const String _keyChapter = 'last_chapter';
  static const String _keyBibleId = 'last_bible_id';
  static const String _keyBibleName = 'last_bible_name';
  static const String _keyTimestamp = 'last_read_timestamp';
  static const String _keyVersePosition = 'last_verse_position';
  
  static SharedPreferences? _prefs;
  static ContinueReadingData? _cache;
  
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✓ ContinueReadingService initialized');
    } catch (e) {
      print('⚠ ContinueReadingService init error: $e');
    }
  }
  
  /// Save current reading position
  static Future<void> savePosition({
    required String bookId,
    required String bookName,
    required int chapter,
    required String bibleId,
    required String bibleName,
    int versePosition = 0,
  }) async {
    try {
      if (_prefs == null) await init();
      if (_prefs == null) return;
      
      final now = DateTime.now().toIso8601String();
      await _prefs!.setString(_keyBookId, bookId);
      await _prefs!.setString(_keyBookName, bookName);
      await _prefs!.setInt(_keyChapter, chapter);
      await _prefs!.setString(_keyBibleId, bibleId);
      await _prefs!.setString(_keyBibleName, bibleName);
      await _prefs!.setString(_keyTimestamp, now);
      await _prefs!.setInt(_keyVersePosition, versePosition);
      
      // Update cache
      _cache = ContinueReadingData(
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        bibleId: bibleId,
        bibleName: bibleName,
        lastRead: DateTime.now(),
        versePosition: versePosition,
      );
      
      print('ContinueReadingService: Saved - $bookName $chapter');
    } catch (e) {
      print('ContinueReadingService: Error saving: $e');
    }
  }
  
  /// Get last reading position
  static ContinueReadingData? getLastPosition() {
    try {
      if (_cache != null) return _cache;
      if (_prefs == null) return null;
      
      final bookId = _prefs!.getString(_keyBookId);
      final bookName = _prefs!.getString(_keyBookName);
      final chapter = _prefs!.getInt(_keyChapter);
      
      if (bookId == null || bookName == null || chapter == null) {
        return null;
      }
      
      _cache = ContinueReadingData(
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        bibleId: _prefs!.getString(_keyBibleId) ?? 'kjv',
        bibleName: _prefs!.getString(_keyBibleName) ?? 'King James Version',
        lastRead: DateTime.tryParse(_prefs!.getString(_keyTimestamp) ?? ''),
        versePosition: _prefs!.getInt(_keyVersePosition) ?? 0,
      );
      return _cache;
    } catch (e) {
      print('ContinueReadingService: Error getting position: $e');
      return null;
    }
  }
  
  /// Clear reading history
  static Future<void> clear() async {
    try {
      _cache = null;
      if (_prefs == null) return;
      await _prefs!.remove(_keyBookId);
      await _prefs!.remove(_keyBookName);
      await _prefs!.remove(_keyChapter);
      await _prefs!.remove(_keyBibleId);
      await _prefs!.remove(_keyBibleName);
      await _prefs!.remove(_keyTimestamp);
      await _prefs!.remove(_keyVersePosition);
      print('ContinueReadingService: Cleared');
    } catch (e) {
      print('ContinueReadingService: Error clearing: $e');
    }
  }
  
  /// Check if there's a saved position
  static bool get hasSavedPosition {
    if (_cache != null) return true;
    if (_prefs == null) return false;
    return _prefs!.getString(_keyBookId) != null;
  }
}

/// Data class for reading position
class ContinueReadingData {
  final String bookId;
  final String bookName;
  final int chapter;
  final String bibleId;
  final String bibleName;
  final DateTime? lastRead;
  final int versePosition;
  
  const ContinueReadingData({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.bibleId,
    required this.bibleName,
    this.lastRead,
    this.versePosition = 0,
  });
  
  String get reference => '$bookName $chapter';
  
  String get timeAgo {
    if (lastRead == null) return '';
    final diff = DateTime.now().difference(lastRead!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
