/// Simple global Bible selection state
/// This avoids all the provider complexity
class CurrentBible {
  static String _id = 'kjv';
  
  static String get id => _id;
  static String get abbreviation {
    final map = {
      'kjv': 'KJV', 'geneva': 'GEN', 'wycliffe': 'WYC', 'tyndale': 'TYN',
      'drc': 'DRA', 'asv': 'ASV', 'web': 'WEB', 'ylt': 'YLT', 'akjv': 'AKJV',
      'worsley': 'WOR', 'darby': 'DAR', 'weymouth': 'WNT', 'bbe': 'BBE',
      'litv': 'LITV', 'rotherham': 'REM', 'montgomery': 'MNT', 'murdock': 'MUR',
      'twentieth': 'TCN', 'leb': 'LEB', 'net': 'NET',
    };
    return map[_id] ?? _id.toUpperCase();
  }
  
  static void set(String newId) {
    print('CurrentBible.set: $_id -> $newId');
    _id = newId.toLowerCase();
  }
  
  static void initFromProvider(String? providerId) {
    if (providerId != null && providerId.isNotEmpty) {
      _id = providerId.toLowerCase();
    }
  }
}
