import 'package:readflow/data/models/book.dart';
import 'package:readflow/services/notification_services.dart';

class StaleBookChecker {
  final NotificationServices _notificationServices;

  StaleBookChecker(this._notificationServices);

  Future<void> checkAndNotify(List<Book> books) async {
    final now = DateTime.now();

    for (final book in books) {
      if (book.status != BookStatus.reading) continue;
      if (book.lastReadAt == null) continue;

      final daysSinceRead = now.difference(book.lastReadAt!).inDays;
      if (daysSinceRead >= 3) {
        await _notificationServices.showImmediateNotification(
          id: book.bookId.hashCode,
          title: 'Pick up where you left off',
          body:
              '${book.title} is waiting - page ${book.currentPage} of ${book}',
        );
      }
    }
  }
}
