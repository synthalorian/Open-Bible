import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

/// Bible download manager for managing offline Bible versions
class BibleDownloadManager extends ChangeNotifier {
  static const String _apiBaseUrl = 'https://api.biblebrain.com/v1';
  
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
      isBundled: false,
      isPublicDomain: true,
      sizeMB: 4.8,
      description: '1901 revision',
    ),
    'bbe': BibleVersionInfo(
      id: 'bbe',
      name: 'Bible in Basic English',
      abbreviation: 'BBE',
      language: 'English',
      isBundled: false,
      isPublicDomain: true,
      sizeMB: 3.5,
      description: 'Simplified English vocabulary',
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
      print('Error loading download state: $e');
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
      print('Error saving download state: $e');
    }
  }
  
  /// Check if a version is available (bundled or downloaded)
  bool isVersionAvailable(String versionId) {
    final version = _availableVersions[versionId];
    if (version == null) return false;
    
    return version.isBundled || (_downloadedVersions[versionId] ?? false);
  }
  
  /// Download a Bible version
  Future<bool> downloadVersion(String versionId) async {
    final version = _availableVersions[versionId];
    if (version == null || version.isBundled) return false;
    
    _downloadProgress[versionId] = DownloadProgress(
      versionId: versionId,
      status: DownloadStatus.downloading,
      progress: 0.0,
    );
    notifyListeners();
    
    try {
      // Simulate download for now - in production, this would download from API
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        _downloadProgress[versionId] = DownloadProgress(
          versionId: versionId,
          status: DownloadStatus.downloading,
          progress: i / 10,
        );
        notifyListeners();
      }
      
      // Mark as downloaded
      _downloadedVersions[versionId] = true;
      _downloadProgress[versionId] = DownloadProgress(
        versionId: versionId,
        status: DownloadStatus.completed,
        progress: 1.0,
      );
      
      await _saveDownloadedVersions();
      notifyListeners();
      return true;
      
    } catch (e) {
      _downloadProgress[versionId] = DownloadProgress(
        versionId: versionId,
        status: DownloadStatus.error,
        progress: 0.0,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }
  
  /// Delete a downloaded version
  Future<void> deleteVersion(String versionId) async {
    final version = _availableVersions[versionId];
    if (version == null || version.isBundled) return;
    
    _downloadedVersions[versionId] = false;
    await _saveDownloadedVersions();
    notifyListeners();
  }
  
  /// Get list of available versions for download
  List<BibleVersionInfo> get downloadableVersions {
    return _availableVersions.values
        .where((v) => !v.isBundled)
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
