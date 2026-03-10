import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../providers/app_providers.dart';

/// Notification service for daily verses and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await android?.requestNotificationsPermission() ?? false;
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    ) ?? false;

    return androidGranted || iosGranted;
  }

  /// Schedule daily verse notification
  Future<void> scheduleDailyVerse({
    required int hour,
    required int minute,
    String title = 'Daily Verse',
    String body = 'Tap to read today\'s verse',
  }) async {
    await _notifications.zonedSchedule(
      1, // Daily verse notification ID
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_verse',
          'Daily Verse',
          channelDescription: 'Daily verse notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel daily verse notification
  Future<void> cancelDailyVerse() async {
    await _notifications.cancel(1);
  }

  /// Show streak reminder notification
  Future<void> showStreakReminder({
    int streak = 0,
  }) async {
    await _notifications.show(
      2, // Streak reminder notification ID
      'Keep your streak going! 🔥',
      'You\'ve read $streak days in a row. Don\'t break the chain!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminder',
          'Streak Reminders',
          channelDescription: 'Reading streak reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Get next instance of given time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to relevant screen
    final payload = response.payload;
    debugPrint('Notification tapped: $payload');
  }
}

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for scheduling daily verse notifications
final dailyVerseNotificationProvider = StateNotifierProvider<
    DailyVerseNotificationNotifier, bool>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final settings = ref.watch(settingsProvider);
  return DailyVerseNotificationNotifier(
    notificationService,
    settings.notificationsEnabled,
    settings.dailyVerseTime.hour,
    settings.dailyVerseTime.minute,
  );
});

class DailyVerseNotificationNotifier extends StateNotifier<bool> {
  final NotificationService _notificationService;
  final int _hour;
  final int _minute;

  DailyVerseNotificationNotifier(
    this._notificationService,
    bool enabled,
    this._hour,
    this._minute,
  ) : super(enabled) {
    if (enabled) {
      _scheduleNotification();
    }
  }

  Future<void> _scheduleNotification() async {
    await _notificationService.scheduleDailyVerse(
      hour: _hour,
      minute: _minute,
    );
  }

  Future<void> enable() async {
    await _scheduleNotification();
    state = true;
  }

  Future<void> disable() async {
    await _notificationService.cancelDailyVerse();
    state = false;
  }

  Future<void> updateTime(int hour, int minute) async {
    if (state) {
      await _notificationService.cancelDailyVerse();
      await _notificationService.scheduleDailyVerse(
        hour: hour,
        minute: minute,
      );
    }
  }
}
