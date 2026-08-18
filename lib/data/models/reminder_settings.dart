import 'package:hive/hive.dart';

part 'reminder_settings.g.dart';
@HiveType(typeId: 3)
class ReminderSettings extends HiveObject {
  @HiveField(0)
  final bool enable;
  @HiveField(1)
  final int hour;
  @HiveField(2)
  final int minute;
  @HiveField(3)
  final List<int> daysOfWeek;

  ReminderSettings({
    this.enable = false,
    this.hour = 20,
    this.minute = 00,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
  });

  ReminderSettings copyWith({
    bool? enable,
    int? hour,
    int? minute,
    List<int>? daysOfWeek,
  }) {
    return ReminderSettings(
      enable: enable ?? this.enable,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }
}
