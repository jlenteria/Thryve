import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import 'reminder_copy.dart';

abstract final class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const DarwinInitializationSettings _darwin =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }
    try {
      tz_data.initializeTimeZones();
      await _useDeviceTimezone();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_launcher'),
          iOS: _darwin,
          macOS: _darwin,
        ),
      );
      _initialized = true;
    } on Object catch (error) {
      // Desktop/test environments may not provide an implementation.
      debugPrint('Thryve: notifications unavailable ($error).');
    }
  }

  /// Schedules (or reschedules) the daily reminder. Returns false when the
  /// platform doesn't support it or the user denied permission.
  static Future<bool> scheduleDaily({
    required int hour,
    required int minute,
    required ReminderCopy copy,
  }) async {
    await initialize();
    if (!_initialized) {
      return false;
    }
    try {
      final bool granted = await _requestPermission();
      if (!granted) {
        return false;
      }
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: AppConstants.dailyReminderId,
        title: copy.title,
        body: copy.body,
        scheduledDate: next,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_focus',
            'Daily focus reminders',
            channelDescription:
                'Your chosen daily time to work toward your goal',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return true;
    } on Object catch (error) {
      debugPrint('Thryve: could not schedule reminder ($error).');
      return false;
    }
  }

  static Future<void> cancelDaily() async {
    if (!_initialized) {
      return;
    }
    try {
      await _plugin.cancel(id: AppConstants.dailyReminderId);
    } on Object {
      // Notification support is optional on unsupported platforms.
    }
  }

  static Future<bool> _requestPermission() async {
    final bool? android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final bool? ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  static Future<void> _useDeviceTimezone() async {
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Object {
      // Unknown identifier: keep the package default (UTC) rather than
      // guessing a region.
    }
  }
}
