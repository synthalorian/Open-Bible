// Unified Bible Translation Configuration
//
// This provides a single source of truth for all Bible translations,
// mapping dropdown IDs to file names and handling all the complexity
// in one place.

class BibleTranslations {
  /// All available translations with their configurations
  static const List<TranslationInfo> all = [
    // Historical (Pre-1600)
    TranslationInfo(
      id: 'wycliffe',
      fileName: 'wycliffe_bible.json',
      abbreviation: 'WYC',
      fullName: 'Wycliffe Bible (1382)',
      year: 1382,
      category: 'Historical',
    ),
    TranslationInfo(
      id: 'tyndale',
      fileName: 'tyndale_bible.json',
      abbreviation: 'TYN',
      fullName: "Tyndale's Bible (1526)",
      year: 1526,
      category: 'Historical',
    ),
    TranslationInfo(
      id: 'drc',
      fileName: 'drc_bible.json',
      abbreviation: 'DRA',
      fullName: 'Douay-Rheims Catholic (1582)',
      year: 1582,
      category: 'Historical',
    ),
    TranslationInfo(
      id: 'geneva',
      fileName: 'gen_bible.json',
      abbreviation: 'GEN',
      fullName: 'Geneva Bible (1599)',
      year: 1599,
      category: 'Historical',
    ),
    // Classic (1600-1900)
    TranslationInfo(
      id: 'kjv',
      fileName: 'kjv_bible.json',
      abbreviation: 'KJV',
      fullName: 'King James Version (1611)',
      year: 1611,
      category: 'Classic',
    ),
    TranslationInfo(
      id: 'worsley',
      fileName: 'worsley_bible.json',
      abbreviation: 'WOR',
      fullName: 'Worsley Bible (1770)',
      year: 1770,
      category: 'Classic',
    ),
    TranslationInfo(
      id: 'ylt',
      fileName: 'ylt_bible.json',
      abbreviation: 'YLT',
      fullName: "Young's Literal (1862)",
      year: 1862,
      category: 'Classic',
    ),
    TranslationInfo(
      id: 'darby',
      fileName: 'darby_bible.json',
      abbreviation: 'DAR',
      fullName: 'Darby Translation (1884)',
      year: 1884,
      category: 'Classic',
    ),
    TranslationInfo(
      id: 'asv',
      fileName: 'asv_bible.json',
      abbreviation: 'ASV',
      fullName: 'American Standard (1901)',
      year: 1901,
      category: 'Classic',
    ),
    TranslationInfo(
      id: 'weymouth',
      fileName: 'weymouth_bible.json',
      abbreviation: 'WNT',
      fullName: 'Weymouth NT (1903)',
      year: 1903,
      category: 'Classic',
    ),
    // Modern (1900-Present)
    TranslationInfo(
      id: 'twentieth',
      fileName: 'twentieth_bible.json',
      abbreviation: 'TCN',
      fullName: 'Twentieth Century NT',
      year: 1901,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'bbe',
      fileName: 'bbe_bible.json',
      abbreviation: 'BBE',
      fullName: 'Bible in Basic English (1965)',
      year: 1965,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'litv',
      fileName: 'litv_bible.json',
      abbreviation: 'LITV',
      fullName: 'Literal Translation (1976)',
      year: 1976,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'rotherham',
      fileName: 'rotherham_bible.json',
      abbreviation: 'REM',
      fullName: 'Rotherham Emphasized',
      year: 1901,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'montgomery',
      fileName: 'montgomery_bible.json',
      abbreviation: 'MNT',
      fullName: 'Montgomery NT',
      year: 1924,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'murdock',
      fileName: 'murdock_bible.json',
      abbreviation: 'MUR',
      fullName: 'Murdock NT',
      year: 1851,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'akjv',
      fileName: 'akjv_bible.json',
      abbreviation: 'AKJV',
      fullName: 'American King James',
      year: 1999,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'web',
      fileName: 'web_bible.json',
      abbreviation: 'WEB',
      fullName: 'World English Bible',
      year: 2000,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'leb',
      fileName: 'leb_bible.json',
      abbreviation: 'LEB',
      fullName: 'Lexham English Bible',
      year: 2010,
      category: 'Modern',
    ),
    TranslationInfo(
      id: 'net',
      fileName: 'net_bible.json',
      abbreviation: 'NET',
      fullName: 'NET Bible',
      year: 2005,
      category: 'Modern',
    ),
  ];
  
  /// Get translation by ID
  static TranslationInfo? getById(String id) {
    for (final t in all) {
      if (t.id == id.toLowerCase()) return t;
    }
    return null;
  }
  
  /// Get file name for a translation ID
  static String? getFileName(String id) {
    return getById(id)?.fileName;
  }
  
  /// Get abbreviation for a translation ID
  static String getAbbreviation(String id) {
    return getById(id)?.abbreviation ?? id.toUpperCase();
  }
  
  /// Get all IDs
  static List<String> get allIds => all.map((t) => t.id).toList();
  
  /// Get all abbreviations
  static List<String> get allAbbreviations => all.map((t) => t.abbreviation).toList();
  
  /// Get translations by category
  static List<TranslationInfo> getByCategory(String category) {
    return all.where((t) => t.category == category).toList();
  }
  
  /// Total count
  static int get count => all.length;
}

/// Translation info model
class TranslationInfo {
  final String id;           // e.g., "kjv"
  final String fileName;     // e.g., "kjv_bible.json"
  final String abbreviation; // e.g., "KJV"
  final String fullName;     // e.g., "King James Version (1611)"
  final int year;            // e.g., 1611
  final String category;     // e.g., "Classic"
  
  const TranslationInfo({
    required this.id,
    required this.fileName,
    required this.abbreviation,
    required this.fullName,
    required this.year,
    required this.category,
  });
}
