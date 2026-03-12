import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../config/bible_translations.dart';

/// Bible download manager for managing offline Bible versions
class BibleDownloadManager extends ChangeNotifier {
  /// Set of translation IDs that are bundled as app assets.
  /// Derived from BibleTranslations.all so there is a single source of truth.
  static final Set<String> _bundledIds =
      BibleTranslations.allIds.toSet();

  final Map<String, BibleVersionInfo> _availableVersions = {
    'kjv': BibleVersionInfo(
      id: 'kjv',
      name: 'King James Version',
      abbreviation: 'KJV',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 5.2,
      description: 'Classic 1611 translation',
    ),
    'web': BibleVersionInfo(
      id: 'web',
      name: 'World English Bible',
      abbreviation: 'WEB',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 5.1,
      description: 'Modern public domain translation',
    ),
    'asv': BibleVersionInfo(
      id: 'asv',
      name: 'American Standard Version',
      abbreviation: 'ASV',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 4.8,
      description: '1901 revision',
    ),
    'bbe': BibleVersionInfo(
      id: 'bbe',
      name: 'Bible in Basic English',
      abbreviation: 'BBE',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 3.5,
      description: 'Simplified English vocabulary',
    ),
    'geneva': BibleVersionInfo(
      id: 'geneva',
      name: 'Geneva Bible',
      abbreviation: 'GNV',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 4.9,
      description: 'Historic Reformation translation',
    ),
    'ylt': BibleVersionInfo(
      id: 'ylt',
      name: 'Young\'s Literal Translation',
      abbreviation: 'YLT',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 4.7,
      description: 'Formal literal translation',
    ),
    'darby': BibleVersionInfo(
      id: 'darby',
      name: 'Darby Translation',
      abbreviation: 'DBY',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 4.6,
      description: 'John Nelson Darby translation',
    ),
    'akjv': BibleVersionInfo(
      id: 'akjv',
      name: 'American King James',
      abbreviation: 'AKJV',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 5.2,
      description: 'Americanized spelling of the KJV',
    ),
    'leb': BibleVersionInfo(
      id: 'leb',
      name: 'Lexham English Bible',
      abbreviation: 'LEB',
      language: 'English',
      isBundled: true,
      isPublicDomain: false,
      sizeMB: 5.5,
      description: 'Modern literal translation',
    ),
    'net': BibleVersionInfo(
      id: 'net',
      name: 'NET Bible',
      abbreviation: 'NET',
      language: 'English',
      isBundled: true,
      isPublicDomain: false,
      sizeMB: 6.2,
      description: 'New English Translation with notes',
    ),
    'drc': BibleVersionInfo(
      id: 'drc',
      name: 'Douay-Rheims Challoner',
      abbreviation: 'DRA',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 5.8,
      description: 'Historic Catholic translation',
    ),
    'wycliffe': BibleVersionInfo(
      id: 'wycliffe',
      name: 'Wycliffe Bible',
      abbreviation: 'WYC',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 4.5,
      description: 'First English translation (1382)',
    ),
    'tyndale': BibleVersionInfo(
      id: 'tyndale',
      name: 'Tyndale Bible',
      abbreviation: 'TYN',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 4.2,
      description: 'First printed English Bible (1526)',
    ),
    'litv': BibleVersionInfo(
      id: 'litv',
      name: 'Literal Translation',
      abbreviation: 'LITV',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 5.1,
      description: 'Green\'s Literal Translation',
    ),
    'rotherham': BibleVersionInfo(
      id: 'rotherham',
      name: 'Rotherham Emphasized',
      abbreviation: 'REM',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 5.3,
      description: 'Emphasized Bible for study',
    ),
    'montgomery': BibleVersionInfo(
      id: 'montgomery',
      name: 'Montgomery NT',
      abbreviation: 'MNT',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 1.2,
      description: 'Centenary Translation of the NT',
    ),
    'murdock': BibleVersionInfo(
      id: 'murdock',
      name: 'Murdock NT',
      abbreviation: 'MUR',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 1.1,
      description: 'James Murdock\'s Syriac Peshitto',
    ),
    'weymouth': BibleVersionInfo(
      id: 'weymouth',
      name: 'Weymouth NT',
      abbreviation: 'WNT',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 1.3,
      description: 'New Testament in Modern Speech',
    ),
    'worsley': BibleVersionInfo(
      id: 'worsley',
      name: 'Worsley Bible',
      abbreviation: 'WOR',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 4.8,
      description: 'Worsley\'s 1770 translation',
    ),
    'twentieth': BibleVersionInfo(
      id: 'twentieth',
      name: 'Twentieth Century NT',
      abbreviation: 'TCN',
      language: 'English',
      isBundled: true,
      isPublicDomain: true,
      sizeMB: 1.4,
      description: 'First 20th-century modern version',
    ),
  };
  
  final Map<String, DownloadProgress> _downloadProgress = {};
  final Map<String, bool> _downloadedVersions = {};
  
  Map<String, BibleVersionInfo> get availableVersions => _availableVersions;
  Map<String, DownloadProgress> get downloadProgress => _downloadProgress;
  
  /// Initialize and check downloaded versions
  Future<void> init() async {
    await _loadDownloadedVersions();
  }
  
  /// Load which versions have been downloaded
  Future<void> _loadDownloadedVersions() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/bible_downloads.json');
      
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString());
        _downloadedVersions.addAll(
          Map<String, bool>.from(json['downloaded'] ?? {}),
        );
      }
    } catch (e) {
      debugPrint('Error loading download state: $e');
    }
    notifyListeners();
  }
  
  /// Save download state
  Future<void> _saveDownloadedVersions() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/bible_downloads.json');
      
      await file.writeAsString(jsonEncode({
        'downloaded': _downloadedVersions,
      }));
    } catch (e) {
      debugPrint('Error saving download state: $e');
    }
  }
  
  /// Check if a version is available (bundled or downloaded)
  bool isVersionAvailable(String versionId) {
    final version = _availableVersions[versionId];
    if (version == null) return false;
    
    return version.isBundled || (_downloadedVersions[versionId] ?? false);
  }
  
  /// Download a Bible version
  ///
  /// NOTE: Real download is not yet implemented. Only bundled translations
  /// (KJV, WEB) are available offline. This method will report an error
  /// for any non-bundled version.
  Future<bool> downloadVersion(String versionId) async {
    final version = _availableVersions[versionId];
    if (version == null || version.isBundled) return false;

    _downloadProgress[versionId] = DownloadProgress(
      versionId: versionId,
      status: DownloadStatus.error,
      progress: 0.0,
      errorMessage: 'Bible download not yet implemented. Only bundled translations are available.',
    );
    notifyListeners();
    return false;
  }
  
  /// Delete a downloaded version
  Future<void> deleteVersion(String versionId) async {
    final version = _availableVersions[versionId];
    if (version == null || version.isBundled) return;
    
    _downloadedVersions[versionId] = false;
    await _saveDownloadedVersions();
    notifyListeners();
  }
  
  /// Get list of available versions for download.
  /// Only shows versions that are NOT bundled as app assets.
  /// Translations whose JSON files ship in assets/bible_data/ are excluded
  /// because they are already available offline.
  List<BibleVersionInfo> get downloadableVersions {
    return _availableVersions.values
        .where((v) => !v.isBundled && !_bundledIds.contains(v.id))
        .toList();
  }
  
  /// Get list of installed versions
  List<BibleVersionInfo> get installedVersions {
    return _availableVersions.values
        .where((v) => isVersionAvailable(v.id))
        .toList();
  }
  
  /// Get total storage used by downloaded Bibles
  double get totalStorageUsed {
    double total = 0;
    for (final entry in _downloadedVersions.entries) {
      if (entry.value) {
        total += _availableVersions[entry.key]?.sizeMB ?? 0;
      }
    }
    return total;
  }
}

/// Bible version information
class BibleVersionInfo {
  final String id;
  final String name;
  final String abbreviation;
  final String language;
  final bool isBundled;
  final bool isPublicDomain;
  final double sizeMB;
  final String description;
  
  const BibleVersionInfo({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.language,
    required this.isBundled,
    required this.isPublicDomain,
    required this.sizeMB,
    required this.description,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'abbreviation': abbreviation,
    'language': language,
    'isBundled': isBundled,
    'isPublicDomain': isPublicDomain,
    'sizeMB': sizeMB,
    'description': description,
  };
}

/// Download progress for a Bible version
class DownloadProgress {
  final String versionId;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;
  
  const DownloadProgress({
    required this.versionId,
    required this.status,
    required this.progress,
    this.errorMessage,
  });
  
  String get statusText {
    switch (status) {
      case DownloadStatus.idle:
        return 'Not downloaded';
      case DownloadStatus.downloading:
        return 'Downloading... ${(progress * 100).toInt()}%';
      case DownloadStatus.completed:
        return 'Downloaded';
      case DownloadStatus.error:
        return 'Error: $errorMessage';
    }
  }
}

enum DownloadStatus {
  idle,
  downloading,
  completed,
  error,
}
