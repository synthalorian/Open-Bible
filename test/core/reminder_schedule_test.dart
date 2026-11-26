import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:open_bible/core/services/reminder_schedule.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('a local daily reminder is not the same instant as that clock time in UTC', () {
    final utc = tz.getLocation('UTC');
    final ny = tz.getLocation('America/New_York');
    final utcNow = tz.TZDateTime(utc, 2026, 1, 15, 10, 0);
    final nyNow = tz.TZDateTime(ny, 2026, 1, 15, 10, 0);

    final utcReminder = nextDailyReminder(7, 30, location: utc, now: utcNow);
    final nyReminder = nextDailyReminder(7, 30, location: ny, now: nyNow);

    expect(nyReminder.location.name, 'America/New_York');
    expect(nyReminder.hour, 7);
    expect(nyReminder.minute, 30);
    expect(nyReminder.day, 16);
    expect(nyReminder.timeZoneOffset, const Duration(hours: -5));
    expect(utcReminder.timeZoneOffset, Duration.zero);
    expect(nyReminder.isAtSameMomentAs(utcReminder), isFalse);
  });

  test('the default location follows useLocalTimezone', () {
    useLocalTimezone('America/Chicago');
    final now = tz.TZDateTime(tz.local, 2026, 7, 4, 6, 0);
    final scheduled = nextDailyReminder(7, 30, now: now);

    expect(tz.local.name, 'America/Chicago');
    expect(scheduled.location.name, 'America/Chicago');
    expect(scheduled.hour, 7);
    expect(scheduled.minute, 30);
    expect(scheduled.day, 4);
    expect(scheduled.timeZoneOffset, const Duration(hours: -5));
  });

  test('a time that has already passed rolls to the next day', () {
    useLocalTimezone('Pacific/Honolulu');
    final now = tz.TZDateTime(tz.local, 2026, 6, 1, 21, 15);
    final scheduled = nextDailyReminder(21, 15, now: now);
    expect(scheduled.day, 1);
    expect(scheduled.hour, 21);

    final later = nextDailyReminder(21, 15, now: now.add(const Duration(minutes: 1)));
    expect(later.day, 2);
    expect(later.location.name, isNot('UTC'));
  });
}
