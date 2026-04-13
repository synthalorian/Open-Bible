import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/utils/logger.dart';

/// Service for loading and managing Bible map data
class BibleMapService {
  static final BibleMapService _instance = BibleMapService._internal();
  factory BibleMapService() => _instance;
  BibleMapService._internal();

  List<BibleMapData> _maps = [];
  bool _isLoaded = false;

  /// Load map data from JSON
  Future<void> load() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/bible_maps.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> mapsJson = data['maps'] ?? [];
      _maps = mapsJson.map((json) => BibleMapData.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      logDebug('Failed to load Bible maps data: $e');
      _maps = [];
    }
  }

  /// Get all maps
  List<BibleMapData> getAllMaps() => List.unmodifiable(_maps);

  /// Get map by ID
  BibleMapData? getMap(String id) {
    try {
      return _maps.firstWhere((m) => m.id == id);
    } catch (e) {
      logDebug('Failed to find map by ID: $e');
      return null;
    }
  }

  /// Get maps by category
  List<BibleMapData> getMapsByCategory(String category) {
    return _maps.where((m) => 
      m.id.contains(category) || 
      m.title.toLowerCase().contains(category.toLowerCase())
    ).toList();
  }

  /// Search maps
  List<BibleMapData> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _maps.where((m) =>
      m.title.toLowerCase().contains(lowerQuery) ||
      m.description.toLowerCase().contains(lowerQuery) ||
      m.locations.any((l) => l.name.toLowerCase().contains(lowerQuery))
    ).toList();
  }
}

/// Bible Map Data Model
class BibleMapData {
  final String id;
  final String title;
  final String description;
  final String period;
  final String imagePath;
  final List<MapLocation> locations;
  final List<MapRoute> routes;

  BibleMapData({
    required this.id,
    required this.title,
    required this.description,
    required this.period,
    required this.imagePath,
    required this.locations,
    required this.routes,
  });

  factory BibleMapData.fromJson(Map<String, dynamic> json) {
    return BibleMapData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      period: json['period'] ?? '',
      imagePath: json['imagePath'] ?? '',
      locations: (json['locations'] as List? ?? [])
          .map((l) => MapLocation.fromJson(l))
          .toList(),
      routes: (json['routes'] as List? ?? [])
          .map((r) => MapRoute.fromJson(r))
          .toList(),
    );
  }
}

/// Map Location Model
class MapLocation {
  final String name;
  final double lat;
  final double lng;
  final String description;
  final String verse;

  MapLocation({
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    required this.verse,
  });

  factory MapLocation.fromJson(Map<String, dynamic> json) {
    return MapLocation(
      name: json['name'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      verse: json['verse'] ?? '',
    );
  }
}

/// Map Route Model
class MapRoute {
  final String from;
  final String to;
  final String description;

  MapRoute({
    required this.from,
    required this.to,
    required this.description,
  });

  factory MapRoute.fromJson(Map<String, dynamic> json) {
    return MapRoute(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
