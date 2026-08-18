import 'package:hive/hive.dart';
import 'package:readflow/data/models/reading_log.dart';

abstract class ReadingLogRepository {
  List<ReadingLog> getLogsForBook(String id);

  Future<void> addLog(ReadingLog log);
}

class HiveReadingLogRepository implements ReadingLogRepository {
  final Box<ReadingLog> _box;

  HiveReadingLogRepository(this._box);

  @override
  List<ReadingLog> getLogsForBook(String id) =>
      _box.values.where((b) => b.bookId == id).toList();

  @override
  Future<void> addLog(ReadingLog log) => _box.add(log);
}
