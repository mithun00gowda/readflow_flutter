import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:readflow/data/models/reading_log.dart';

import '../data/models/book.dart';

final bookBoxProvider = Provider<Box<Book>>((ref){
  return Hive.box<Book>('books');
});

final readingBoxProvider = Provider<Box<ReadingLog>>((ref){
  return Hive.box<ReadingLog>('reading_log');
});