import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/data/repositories/book_reminders.dart';
import 'package:readflow/data/repositories/book_repository.dart';
import 'package:readflow/data/repositories/reading_log_repository.dart';
import 'package:readflow/providers/hive_providers.dart';

final bookRepositoryProviders = Provider<BookRepository>((ref){
  final box = ref.watch(bookBoxProvider);
  return HiveBookRepository(box);
});

final readingLogsRepositoryProvider = Provider<ReadingLogRepository>((ref){
  final box = ref.watch(readingBoxProvider);
  return HiveReadingLogRepository(box);
});


final bookReminderRepositoryProvider = Provider<BookRemindersRepository>((ref){
  final box = ref.watch(bookReminderBoxProvider);
  return HiveBookReminderRepository(box);
});