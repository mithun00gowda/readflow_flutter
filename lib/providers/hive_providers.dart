import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:readflow/data/models/book_reminder.dart';
import 'package:readflow/data/models/reading_log.dart';

import '../data/models/book.dart';
import '../data/models/reminder_settings.dart';

final bookBoxProvider = Provider<Box<Book>>((ref){
  return Hive.box<Book>('books');
});

final readingBoxProvider = Provider<Box<ReadingLog>>((ref){
  return Hive.box<ReadingLog>('reading_log');
});

final reminderSettingsBoxProvider = Provider<Box<ReminderSettings>>((ref) {
  return Hive.box<ReminderSettings>('reminder_settings');
});

final bookReminderBoxProvider = Provider<Box<BookReminder>>((ref){
  return Hive.box<BookReminder>('book_reminder');
});