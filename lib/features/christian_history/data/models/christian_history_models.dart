import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maps a string icon name to the corresponding IconData.
IconData getHistoryIconData(String iconName) {
  switch (iconName) {
    case 'timeline':
      return Icons.timeline;
    case 'church':
      return Icons.church;
    case 'cross':
      return Icons.close;
    case 'shield':
      return Icons.shield;
    case 'star':
      return Icons.star;
    case 'account_balance':
      return Icons.account_balance;
    case 'map':
      return Icons.map;
    case 'palette':
      return Icons.palette;
    case 'menu_book':
      return Icons.menu_book;
    case 'people':
      return Icons.people;
    case 'swords':
      return Icons.military_tech;
    default:
      return Icons.history_edu;
  }
}

/// Top-level wrapper for all Christian History data.
class ChristianHistoryData {
  final List<HistoryCategory> categories;

  const ChristianHistoryData({required this.categories});

  factory ChristianHistoryData.fromJson(Map<String, dynamic> json) {
    return ChristianHistoryData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => HistoryCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  /// Loads Christian History data from the bundled assets.
  static Future<ChristianHistoryData> load() async {
    final jsonStr = await rootBundle.loadString(
      'assets/data/christian_history/index.json',
    );
    return ChristianHistoryData.fromJson(
      json.decode(jsonStr) as Map<String, dynamic>,
    );
  }
}

/// Represents a category like "Church History", "Denominations", "Crosses", etc.
class HistoryCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<HistoryEntry> entries;

  const HistoryCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.entries,
  });

  factory HistoryCategory.fromJson(Map<String, dynamic> json) {
    return HistoryCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}

/// A single encyclopedia entry used for ALL categories.
class HistoryEntry {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final String? imageUrl;
  final String? period;
  final String? location;
  final String? foundedBy;
  final String? yearFounded;
  final String? headquarters;
  final String? adherents;
  final List<String> keyFigures;
  final List<String> keyEvents;
  final String? crossType;
  final String? origin;
  final List<String> tags;

  const HistoryEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    this.imageUrl,
    this.period,
    this.location,
    this.foundedBy,
    this.yearFounded,
    this.headquarters,
    this.adherents,
    this.keyFigures = const [],
    this.keyEvents = const [],
    this.crossType,
    this.origin,
    this.tags = const [],
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      period: json['period'] as String?,
      location: json['location'] as String?,
      foundedBy: json['foundedBy'] as String?,
      yearFounded: json['yearFounded'] as String?,
      headquarters: json['headquarters'] as String?,
      adherents: json['adherents'] as String?,
      keyFigures: (json['keyFigures'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      keyEvents: (json['keyEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      crossType: json['crossType'] as String?,
      origin: json['origin'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'period': period,
      'location': location,
      'foundedBy': foundedBy,
      'yearFounded': yearFounded,
      'headquarters': headquarters,
      'adherents': adherents,
      'keyFigures': keyFigures,
      'keyEvents': keyEvents,
      'crossType': crossType,
      'origin': origin,
      'tags': tags,
    };
  }
}
