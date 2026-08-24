import 'package:hive/hive.dart';
import 'package:readflow/data/models/reading_log.dart';

abstract class ReadingLogRepository {
  List<ReadingLog> getAllReadingLogs();
}

class HiveReadingLogRepository implements ReadingLogRepository{

  final Box<ReadingLog> _book;

  HiveReadingLogRepository({required this._book});


  @override
  List<ReadingLog> getAllReadingLogs() => _book.values.toList();

}