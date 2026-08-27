import 'package:hive/hive.dart';

part 'reading_log.g.dart';

@HiveType(typeId: 2)
class ReadingLog extends HiveObject{
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String bookId;
  @HiveField(2)
  final int fromPage;
  @HiveField(3)
  final int toPage;
  @HiveField(4)
  final DateTime timeStamp;
  @HiveField(5)
  final int? sessionDurationMinutes;

  ReadingLog({
    required this.id,
    required this.bookId,
    required this.fromPage,
    required this.toPage,
    required this.timeStamp,
     this.sessionDurationMinutes,
  });

  int get pagesRead => toPage - fromPage;
  int get pagesReadPositive => pagesRead > 0 ? pagesRead : 0;
}
