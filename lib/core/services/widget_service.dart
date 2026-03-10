import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// Home screen widget service
class WidgetService {
  static const String _widgetName = 'DailyVerseWidget';
  static const String _appGroupId = 'com.faith.holybible';

  /// Initialize home widget
  Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Update daily verse widget
  Future<void> updateDailyVerse({
    required String reference,
    required String text,
  }) async {
    await HomeWidget.saveWidgetData('verse_reference', reference);
    await HomeWidget.saveWidgetData('verse_text', text);
    await HomeWidget.updateWidget(
      iOSName: _widgetName,
      androidName: _widgetName,
    );
  }

  /// Clear widget data
  Future<void> clearWidget() async {
    await HomeWidget.saveWidgetData('verse_reference', null);
    await HomeWidget.saveWidgetData('verse_text', null);
    await HomeWidget.updateWidget(
      iOSName: _widgetName,
      androidName: _widgetName,
    );
  }

  /// Get widget data (for when widget is tapped)
  Future<String?> getWidgetData(String key) async {
    return await HomeWidget.getWidgetData(key);
  }

  /// Register callback for widget tap
  void registerCallback(VoidCallback onTap) {
    HomeWidget.widgetClicked.listen((uri) {
      onTap();
    });
  }
}

/// Provider for widget service
final widgetServiceProvider = Provider<WidgetService>((ref) {
  final service = WidgetService();
  service.init();
  return service;
});
