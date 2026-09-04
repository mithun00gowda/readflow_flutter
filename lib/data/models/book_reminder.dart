import 'package:hive/hive.dart';

part 'book_reminder.g.dart';

@HiveType(typeId: 4)
class BookReminder extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String label;
  @HiveField(2)
  final int hour;
  @HiveField(3)
  final int minute;
  @HiveField(4)
  final bool enabled;
  @HiveField(5)
  final String? bookID;
  @HiveField(6)
  final List<int> daysOfWeek;

  BookReminder({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
     this.enabled = true,
     this.bookID,
     this.daysOfWeek =const [1,2,3,4,5,6,7],
  });

  BookReminder copyWith({
    String? label,
    int? hour,
    int? minute,
    bool? enabled,
    String? bookID,
    List<int>? daysOfWeek,
  }) {
    return BookReminder(
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      bookID: bookID ?? this.bookID,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }
// book_reminder.dart — add alongside the existing notificationId getter
  int notificationIdForDay(int weekday) => '${id}_day$weekday'.hashCode & 0x7FFFFFFF;
  int get notificationId => id.hashCode & 0x7FFFFFFF;
}
