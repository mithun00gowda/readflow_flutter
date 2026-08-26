
import 'package:hive/hive.dart';
import 'package:readflow/data/models/book_reminder.dart';

abstract class BookRemindersRepository {
  List<BookReminder> getAll();
  Future<void> save(BookReminder reminder);
  Future<void> delect(String id);
}


class HiveBookReminderRepository implements BookRemindersRepository{
 final Box<BookReminder> _box;
  HiveBookReminderRepository( this._box);

  @override
  List<BookReminder> getAll() => _box.values.toList();

  @override
  Future<void> save(BookReminder reminder) => _box.put(reminder.id, reminder);

  @override
  Future<void> delect(String id) => _box.delete(id);

}