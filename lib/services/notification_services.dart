import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
class NotificationServices {
  final _pugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async{
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
     const iosSettings =  DarwinInitializationSettings(
       requestAlertPermission: true,
       requestBadgePermission: true,
       requestSoundPermission: true,
     );

     await _pugin.initialize(settings: const InitializationSettings(android: androidSettings,iOS: iosSettings));

     await _pugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
     await _pugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();

  }

  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
}) async{
    await _pugin.zonedSchedule(id: id,title: title,body: body,scheduledDate: _nextInstanceOfTime(hour,minute),notificationDetails: const NotificationDetails(android: AndroidNotificationDetails('daily_reminder','Daily Reading Reminder',importance: Importance.high,priority: Priority.high),iOS: DarwinNotificationDetails(),),androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> cancel(int id) => _pugin.cancel(id: id);
  Future<void> cancelAll() => _pugin.cancelAll();
  tz.TZDateTime _nextInstanceOfTime(int hour,int minute){
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local,now.year,now.month,now.day,hour,minute);
    if (scheduled.isBefore(now)){
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}