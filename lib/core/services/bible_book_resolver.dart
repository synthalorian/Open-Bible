/// Exact Bible book identity for USFM codes, full names, and numbered books.
///
/// Lookups compare a normalized key (lowercase, letters and digits only) against
/// a fixed alias table. Prefix matching is intentionally not used: "JUD" is Jude,
/// and "judges" is Judges.
class BibleBookId {
  final String usfm;
  final String name;

  const BibleBookId(this.usfm, this.name);

  @override
  bool operator ==(Object other) =>
      other is BibleBookId && other.usfm == usfm;

  @override
  int get hashCode => usfm.hashCode;
}

/// Canonical Protestant canon in Bible order.
const List<BibleBookId> kBibleBooks = [
  BibleBookId('GEN', 'Genesis'),
  BibleBookId('EXO', 'Exodus'),
  BibleBookId('LEV', 'Leviticus'),
  BibleBookId('NUM', 'Numbers'),
  BibleBookId('DEU', 'Deuteronomy'),
  BibleBookId('JOS', 'Joshua'),
  BibleBookId('JDG', 'Judges'),
  BibleBookId('RUT', 'Ruth'),
  BibleBookId('1SA', '1 Samuel'),
  BibleBookId('2SA', '2 Samuel'),
  BibleBookId('1KI', '1 Kings'),
  BibleBookId('2KI', '2 Kings'),
  BibleBookId('1CH', '1 Chronicles'),
  BibleBookId('2CH', '2 Chronicles'),
  BibleBookId('EZR', 'Ezra'),
  BibleBookId('NEH', 'Nehemiah'),
  BibleBookId('EST', 'Esther'),
  BibleBookId('JOB', 'Job'),
  BibleBookId('PSA', 'Psalms'),
  BibleBookId('PRO', 'Proverbs'),
  BibleBookId('ECC', 'Ecclesiastes'),
  BibleBookId('SNG', 'Song of Solomon'),
  BibleBookId('ISA', 'Isaiah'),
  BibleBookId('JER', 'Jeremiah'),
  BibleBookId('LAM', 'Lamentations'),
  BibleBookId('EZK', 'Ezekiel'),
  BibleBookId('DAN', 'Daniel'),
  BibleBookId('HOS', 'Hosea'),
  BibleBookId('JOL', 'Joel'),
  BibleBookId('AMO', 'Amos'),
  BibleBookId('OBA', 'Obadiah'),
  BibleBookId('JON', 'Jonah'),
  BibleBookId('MIC', 'Micah'),
  BibleBookId('NAM', 'Nahum'),
  BibleBookId('HAB', 'Habakkuk'),
  BibleBookId('ZEP', 'Zephaniah'),
  BibleBookId('HAG', 'Haggai'),
  BibleBookId('ZEC', 'Zechariah'),
  BibleBookId('MAL', 'Malachi'),
  BibleBookId('MAT', 'Matthew'),
  BibleBookId('MRK', 'Mark'),
  BibleBookId('LUK', 'Luke'),
  BibleBookId('JHN', 'John'),
  BibleBookId('ACT', 'Acts'),
  BibleBookId('ROM', 'Romans'),
  BibleBookId('1CO', '1 Corinthians'),
  BibleBookId('2CO', '2 Corinthians'),
  BibleBookId('GAL', 'Galatians'),
  BibleBookId('EPH', 'Ephesians'),
  BibleBookId('PHP', 'Philippians'),
  BibleBookId('COL', 'Colossians'),
  BibleBookId('1TH', '1 Thessalonians'),
  BibleBookId('2TH', '2 Thessalonians'),
  BibleBookId('1TI', '1 Timothy'),
  BibleBookId('2TI', '2 Timothy'),
  BibleBookId('TIT', 'Titus'),
  BibleBookId('PHM', 'Philemon'),
  BibleBookId('HEB', 'Hebrews'),
  BibleBookId('JAS', 'James'),
  BibleBookId('1PE', '1 Peter'),
  BibleBookId('2PE', '2 Peter'),
  BibleBookId('1JN', '1 John'),
  BibleBookId('2JN', '2 John'),
  BibleBookId('3JN', '3 John'),
  BibleBookId('JUD', 'Jude'),
  BibleBookId('REV', 'Revelation'),
];

/// Extra exact aliases beyond the USFM code and the English name.
const Map<String, List<String>> kBibleBookExtraAliases = {
  'GEN': ['Gen', 'Ge'],
  'EXO': ['Exo', 'Exod', 'Ex'],
  'LEV': ['Lev'],
  'NUM': ['Num'],
  'DEU': ['Deu', 'Deut', 'Dt'],
  'JOS': ['Jos', 'Josh'],
  'JDG': ['Jdg', 'Judg'],
  'RUT': ['Rut', 'Ru'],
  '1SA': ['1Sa', '1Sam', 'I Samuel', '1st Samuel'],
  '2SA': ['2Sa', '2Sam', 'II Samuel', '2nd Samuel'],
  '1KI': ['1Ki', '1Kgs', 'I Kings', '1st Kings'],
  '2KI': ['2Ki', '2Kgs', 'II Kings', '2nd Kings'],
  '1CH': ['1Ch', '1Chr', 'I Chronicles', '1st Chronicles'],
  '2CH': ['2Ch', '2Chr', 'II Chronicles', '2nd Chronicles'],
  'EZR': ['Ezr'],
  'NEH': ['Neh'],
  'EST': ['Est'],
  'JOB': ['Job'],
  'PSA': ['Psa', 'Psalm', 'Ps', 'Psm'],
  'PRO': ['Pro', 'Prov'],
  'ECC': ['Ecc', 'Eccl'],
  'SNG': [
    'Song of Songs',
    'Canticles',
    'Canticle of Canticles',
    'Sos',
  ],
  'ISA': ['Isa'],
  'JER': ['Jer'],
  'LAM': ['Lam'],
  'EZK': ['Eze', 'Ezk'],
  'DAN': ['Dan'],
  'HOS': ['Hos'],
  'JOL': ['Joe', 'Joel'],
  'AMO': ['Amo'],
  'OBA': ['Oba', 'Obad'],
  'JON': ['Jon'],
  'MIC': ['Mic'],
  'NAM': ['Nah', 'Nam'],
  'HAB': ['Hab'],
  'ZEP': ['Zep', 'Zeph'],
  'HAG': ['Hag'],
  'ZEC': ['Zec', 'Zech'],
  'MAL': ['Mal'],
  'MAT': ['Mat', 'Matt'],
  'MRK': ['Mar', 'Mk'],
  'LUK': ['Luk', 'Lk'],
  'JHN': ['Joh', 'Jn'],
  'ACT': ['Act'],
  'ROM': ['Rom'],
  '1CO': ['1Co', '1Cor', 'I Corinthians', '1st Corinthians'],
  '2CO': ['2Co', '2Cor', 'II Corinthians', '2nd Corinthians'],
  'GAL': ['Gal'],
  'EPH': ['Eph'],
  'PHP': ['Phi', 'Phil'],
  'COL': ['Col'],
  '1TH': ['1Th', '1Thess', 'I Thessalonians', '1st Thessalonians'],
  '2TH': ['2Th', '2Thess', 'II Thessalonians', '2nd Thessalonians'],
  '1TI': ['1Ti', '1Tim', 'I Timothy', '1st Timothy'],
  '2TI': ['2Ti', '2Tim', 'II Timothy', '2nd Timothy'],
  'TIT': ['Tit'],
  'PHM': ['Phm'],
  'HEB': ['Heb'],
  'JAS': ['Jam', 'Jas'],
  '1PE': ['1Pe', '1Pet', 'I Peter', '1st Peter'],
  '2PE': ['2Pe', '2Pet', 'II Peter', '2nd Peter'],
  '1JN': ['1Jo', '1Jn', 'I John', '1st John'],
  '2JN': ['2Jo', '2Jn', 'II John', '2nd John'],
  '3JN': ['3Jo', '3Jn', 'III John', '3rd John'],
  'JUD': ['Jud'],
  'REV': ['Rev', 'Apocalypse'],
};

String normalizeBookKey(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

final Map<String, BibleBookId> _aliasIndex = _buildAliasIndex();

Map<String, BibleBookId> _buildAliasIndex() {
  final index = <String, BibleBookId>{};
  for (final book in kBibleBooks) {
    final aliases = <String>[
      book.usfm,
      book.name,
      ...?kBibleBookExtraAliases[book.usfm],
    ];
    for (final alias in aliases) {
      final key = normalizeBookKey(alias);
      if (key.isEmpty) {
        throw StateError('Empty book alias for ${book.usfm}');
      }
      final existing = index[key];
      if (existing != null && existing.usfm != book.usfm) {
        throw StateError(
          'Book alias "$key" is used by both ${existing.usfm} and ${book.usfm}',
        );
      }
      index[key] = book;
    }
  }
  return index;
}

/// Resolve [value] to one canon book, or null when it is not an exact alias.
BibleBookId? resolveBibleBook(String value) {
  final key = normalizeBookKey(value);
  if (key.isEmpty) return null;
  return _aliasIndex[key];
}

/// Whether [jsonId] or [jsonName] is the same canon book as [requested].
bool bibleBookMatches(String requested, String jsonId, String jsonName) {
  final want = resolveBibleBook(requested);
  if (want == null) return false;
  final byId = resolveBibleBook(jsonId);
  if (byId != null && byId.usfm == want.usfm) return true;
  final byName = resolveBibleBook(jsonName);
  return byName != null && byName.usfm == want.usfm;
}

/// First book object in a bundled Bible JSON whose id or name matches [bookId].
Map<String, dynamic>? findBibleBook(List<dynamic> books, String bookId) {
  for (final book in books) {
    if (book is! Map) continue;
    final id = book['id']?.toString() ?? '';
    final name = book['name']?.toString() ?? '';
    if (bibleBookMatches(bookId, id, name)) {
      return Map<String, dynamic>.from(book);
    }
  }
  return null;
}

/// Exposed for tests that want to assert the alias table has no collisions.
Map<String, String> bibleBookAliasIndexForTest() => {
      for (final entry in _aliasIndex.entries) entry.key: entry.value.usfm,
    };
