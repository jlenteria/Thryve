import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    try {
      tz_data.initializeTimeZones();
      // Thryve currently targets the Philippine locale used by its currency and copy.
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _initialized = true;
    } on Object {
      // Desktop/test environments may not provide a notifications implementation.
    }
  }

  static Future<bool> scheduleDaily({
    required int hour,
    required int minute,
    required String anchor,
  }) async {
    if (kIsWeb) return false;
    await initialize();
    if (!_initialized) return false;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: 1001,
        title: 'Time to Thryve',
        body: '30 focused minutes today, for $anchor.',
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
    } on Object {
      return false;
    }
  }

  static Future<void> cancelDaily() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: 1001);
    } on Object {
      // Notification support is optional on unsupported platforms.
    }
  }
}
