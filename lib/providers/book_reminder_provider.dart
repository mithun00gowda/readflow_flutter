import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/data/models/book_reminder.dart';
import 'package:readflow/providers/repository_providers.dart';
import 'package:readflow/providers/services_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class BookReminderNotifier extends Notifier<List<BookReminder>> {
  @override
  List<BookReminder> build() {
    return ref.watch(bookReminderRepositoryProvider).getAll();
  }

  Future<void> addRemindre({
    required String label,
    required int hour,
    required int minute,
    String? bookId,
  }) async {
    final reminder = BookReminder(
      id: _uuid.v4(),
      label: label,
      hour: hour,
      minute: minute,
      bookID: bookId,
    );
    await _saveAndSchedule(reminder);
  }

  Future<void> toggleEnable(BookReminder reminder) async {
    final updated = reminder.copyWith(enabled: !reminder.enabled);
    await _saveAndSchedule(updated);
  }

  Future<void> updateTime(BookReminder reminder, int hour, int minute) async {
    final updated = reminder.copyWith(hour: hour, minute: minute);
    await _saveAndSchedule(updated);
  }

  Future<void> deleteRemindre(BookReminder reminder) async {
    await ref.read(bookReminderRepositoryProvider).delect(reminder.id);
    await ref
        .read(notificationServicesProviders)
        .cancel(reminder.notificationId);
    state = ref.read(bookReminderRepositoryProvider).getAll();
  }

  // book_reminder_provider.dart
  Future<void> _saveAndSchedule(BookReminder reminder) async {
    await ref.read(bookReminderRepositoryProvider).save(reminder);
    final notifier = ref.read(notificationServicesProviders);

    // Always cancel all 7 possible day-slots first — simplest way to guarantee
    // no stale schedule lingers from a previous save with different days selected.
    for (var day = 1; day <= 7; day++) {
      await notifier.cancel(reminder.notificationIdForDay(day));
    }

    if (reminder.enabled) {
      String? imagePath;
      if (reminder.id != null) {
        final book = ref
            .read(bookRepositoryProviders)
            .getBookById(reminder.id!);
        imagePath = book?.coverImagePath;
      }

      for (final day in reminder.daysOfWeek) {
        await notifier.scheduleWeeklyReminder(
          id: reminder.notificationIdForDay(day),
          weekday: day,
          hour: reminder.hour,
          minute: reminder.minute,
          title: reminder.label,
          body: 'Time for your reading session 📖',
          imagePath: imagePath,
        );
      }
    }
    state = ref.read(bookReminderRepositoryProvider).getAll();
  }

  // lib/providers/book_reminder_provider.dart — updated

  Future<void> addReminder({
    required String label,
    required int hour,
    required int minute,
    required List<int> selectedDays,
    String? bookId,
  }) async {
    final reminder = BookReminder(
      id: _uuid.v4(),
      label: label,
      daysOfWeek: selectedDays,
      hour: hour,
      minute: minute,
      bookID: bookId,
    );
    await _saveAndSchedule(reminder);
  }

  Future<void> editReminder(
    BookReminder existing, {
    required String label,
    required int hour,
    required int minute,
    required List<int> selectedDays,
    String? bookId,
  }) async {
    final updated = existing.copyWith(
      label: label,
      daysOfWeek: selectedDays,
      hour: hour,
      minute: minute,
      bookID: bookId,
    );
    await _saveAndSchedule(updated);
  }
}

final bookReminderProvider =
    NotifierProvider<BookReminderNotifier, List<BookReminder>>(() {
      return BookReminderNotifier();
    });
