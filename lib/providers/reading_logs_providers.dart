import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/data/models/reading_log.dart';
import 'package:readflow/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class ReadingLogsNotifier extends Notifier<List<ReadingLog>> {
  @override
  List<ReadingLog> build() => [];

  void logProgress(String bookId, int fromPage, int toPage) {
    final id = _uuid.v4();
    final log = ReadingLog(
      id: id,
      bookId: bookId,
      fromPage: fromPage,
      toPage: toPage,
      timeStamp: DateTime.now(),
    );

    ref.read(readingLogsRepositoryProvider).addLog(log);
    state = [...state,log];
  }

}

final readingLogsProvider = NotifierProvider<ReadingLogsNotifier,List<ReadingLog>>((){
  return ReadingLogsNotifier();
});
