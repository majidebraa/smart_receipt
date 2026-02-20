import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _noti =
  FlutterLocalNotificationsPlugin();

  /// ──────────────────────────────
  /// Initialize Notifications
  /// ──────────────────────────────
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _noti.initialize(settings:settings);

    // Ask Android 13+ notification permission
    await _noti
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// ──────────────────────────────
  /// Schedule Reminder Notification
  /// ──────────────────────────────
  static Future<void> scheduleReminder({
    required String id,
    required String title,
    required DateTime dateTime,
  }) async {
    final android = AndroidNotificationDetails(
      'reminder_channel', // channelId
      'Reminders',        // channelName
      channelDescription: 'Bill reminders channel', // must provide in v20
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const ios = DarwinNotificationDetails();

    final platform = NotificationDetails(android: android, iOS: ios);

    await _noti.zonedSchedule(
      id:id.hashCode,
      body: 'Bill Reminder',
      title: title,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: platform,
      payload: id,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// ──────────────────────────────
  /// Cancel Notification
  /// ──────────────────────────────
  static Future<void> cancelReminder(String id) async {
    await _noti.cancel(id: id.hashCode);
  }
}