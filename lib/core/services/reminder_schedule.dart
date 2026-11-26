import 'package:timezone/timezone.dart' as tz;

/// Next occurrence of [hour]:[minute] on the clock of [location].
///
/// [location] defaults to [tz.local]. Callers that schedule reminders must set
/// [tz.local] to the device zone first; the timezone package leaves it at UTC
/// until [tz.setLocalLocation] runs.
tz.TZDateTime nextDailyReminder(
  int hour,
  int minute, {
  tz.Location? location,
  tz.TZDateTime? now,
}) {
  final loc = location ?? tz.local;
  final clock = now ?? tz.TZDateTime.now(loc);
  var scheduled = tz.TZDateTime(
    loc,
    clock.year,
    clock.month,
    clock.day,
    hour,
    minute,
  );
  if (scheduled.isBefore(clock)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

/// Point [tz.local] at an IANA timezone such as `America/New_York`.
void useLocalTimezone(String ianaName) {
  tz.setLocalLocation(tz.getLocation(ianaName));
}
