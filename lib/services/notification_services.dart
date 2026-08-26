import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationServices {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Timezone database + device's real local zone
    tz_data.initializeTimeZones();
    final TimezoneInfo deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    final String resolvedTimezone = _resolveTimezoneAlias(deviceTimeZone.identifier);

    try {
      tz.setLocalLocation(tz.getLocation(resolvedTimezone));
      debugPrint('📍 Device timezone set to: $resolvedTimezone');
    } catch (e) {
      debugPrint('⚠️ Unknown timezone "$resolvedTimezone", falling back to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Platform init settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // 3. iOS permission (explicit, in addition to the request flags above)
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🍎 iOS permission result: $iosGranted');

    // 4. Android notification channel (required on API 26+)
    const channel = AndroidNotificationChannel(
      'daily_reminder',
      'Daily Reading Reminder',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    debugPrint('✅ notification channel created');

    // 5. Android runtime notification permission (API 33+)
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    debugPrint('🔓 Android notification permission granted: $androidGranted');

    // 6. Android exact alarm permission (API 31+, no-op / null below that)
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('exact alarm perm request skipped: $e');
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);
    debugPrint('🔔 Scheduling for: $scheduledTime (now: ${tz.TZDateTime.now(tz.local)})');

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reading Reminder',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('✅ zonedSchedule completed without error');
    } catch (e, st) {
      debugPrint('❌ zonedSchedule threw: $e');
      debugPrint('$st');
    }
  }

  /// One-off nudge: "haven't read book X in 3+ days" (Phase 5 next step will call this)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'book_nudge',
          'Reading Nudges',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
  Future<void> cancelAll() => _plugin.cancelAll();

  String _resolveTimezoneAlias(String identifier) {
    const aliases = {
      'Asia/Calcutta': 'Asia/Kolkata',
      'Asia/Saigon': 'Asia/Ho_Chi_Minh',
      'Asia/Rangoon': 'Asia/Yangon',
    };
    return aliases[identifier] ?? identifier;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // lib/services/notification_services.dart — add this method
  Future<void> scheduleBookReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    String? imagePath,
  }) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    AndroidNotificationDetails androidDetails;
    List<DarwinNotificationAttachment>? iosAttachments;

    if (imagePath != null) {
      androidDetails = AndroidNotificationDetails(
        'book_reminder',
        'Book Reminders',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap(imagePath),
          largeIcon: FilePathAndroidBitmap(imagePath),
          contentTitle: title,
          summaryText: body,
        ),
      );
      iosAttachments = [DarwinNotificationAttachment(imagePath)];
    } else {
      androidDetails = const AndroidNotificationDetails(
        'book_reminder',
        'Book Reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          attachments: iosAttachments,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}