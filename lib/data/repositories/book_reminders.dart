
import 'package:readflow/data/models/book_reminder.dart';

abstract class BookRemindersRepository {
  List<BookReminder> getAll();
  Future<void> save(BookReminder reminder);
  Future<void> delect(String id);
}


class HiveBookReminderRepository implements BookRemindersRepository{

}