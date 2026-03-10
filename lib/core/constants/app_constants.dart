/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Open Bible';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String bibleApiBaseUrl = 'https://api.scripture.api.bible/v1';
  
  // API Key - loaded from .env file at runtime
  static String get bibleApiKey {
    // Import dotenv in the file that uses this
    // This is a placeholder - actual key comes from .env
    return const String.fromEnvironment('BIBLE_API_KEY', defaultValue: '');
  }

  // Default Values
  static const String defaultTranslation = 'de4e12af7f28f599-02'; // ESV
  static const int defaultFontSize = 18;
  static const int minFontSize = 12;
  static const int maxFontSize = 32;

  // Cache Duration
  static const Duration cacheDuration = Duration(days: 7);

  // Reading Streak
  static const int streakGraceHours = 4; // Hours after midnight before streak breaks

  // Pagination
  static const int versesPerPage = 50;
  static const int searchResultsLimit = 100;

  // Notification IDs
  static const int dailyVerseNotificationId = 1;
  static const int readingReminderNotificationId = 2;
  static const int streakWarningNotificationId = 3;
}

/// Bible book structure
class BibleStructure {
  BibleStructure._();

  static const List<String> oldTestament = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
    'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
    '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
    'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
    'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations',
    'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
    'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
  ];

  static const List<String> newTestament = [
    'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
    'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy',
    '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James',
    '1 Peter', '2 Peter', '1 John', '2 John', '3 John',
    'Jude', 'Revelation',
  ];

  static const Map<String, int> chapterCounts = {
    'Genesis': 50, 'Exodus': 40, 'Leviticus': 27, 'Numbers': 36, 'Deuteronomy': 34,
    'Joshua': 24, 'Judges': 21, 'Ruth': 4, '1 Samuel': 31, '2 Samuel': 24,
    '1 Kings': 22, '2 Kings': 25, '1 Chronicles': 29, '2 Chronicles': 36, 'Ezra': 10,
    'Nehemiah': 13, 'Esther': 10, 'Job': 42, 'Psalms': 150, 'Proverbs': 31,
    'Ecclesiastes': 12, 'Song of Solomon': 8, 'Isaiah': 66, 'Jeremiah': 52, 'Lamentations': 5,
    'Ezekiel': 48, 'Daniel': 12, 'Hosea': 14, 'Joel': 3, 'Amos': 9,
    'Obadiah': 1, 'Jonah': 4, 'Micah': 7, 'Nahum': 3, 'Habakkuk': 3,
    'Zephaniah': 3, 'Haggai': 2, 'Zechariah': 14, 'Malachi': 4,
    'Matthew': 28, 'Mark': 16, 'Luke': 24, 'John': 21, 'Acts': 28,
    'Romans': 16, '1 Corinthians': 16, '2 Corinthians': 13, 'Galatians': 6, 'Ephesians': 6,
    'Philippians': 4, 'Colossians': 4, '1 Thessalonians': 5, '2 Thessalonians': 3, '1 Timothy': 6,
    '2 Timothy': 4, 'Titus': 3, 'Philemon': 1, 'Hebrews': 13, 'James': 5,
    '1 Peter': 5, '2 Peter': 3, '1 John': 5, '2 John': 1, '3 John': 1,
    'Jude': 1, 'Revelation': 22,
  };

  static List<String> get allBooks => [...oldTestament, ...newTestament];
  
  static bool isOldTestament(String book) => oldTestament.contains(book);
  static bool isNewTestament(String book) => newTestament.contains(book);
  
  static int getChapterCount(String book) => chapterCounts[book] ?? 0;
}
