import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/providers/book_reminder_provider.dart';
import 'package:readflow/providers/repository_providers.dart';
import 'package:readflow/providers/services_provider.dart';

import '../core/widgets/app_toast.dart';

class BookNotifier extends Notifier<List<Book>> {
  @override
  List<Book> build() {
    return ref.watch(bookRepositoryProviders).getAllBooks();
  }

  void addBook(Book book) {
    ref.read(bookRepositoryProviders).addBook(book);
    state = ref.watch(bookRepositoryProviders).getAllBooks();
  }

  // inside BookNotifier
  void updateBook(String bookId, int newPage) {
    final repo = ref.read(bookRepositoryProviders);
    final book = repo.getBookById(bookId);
    if (book == null) return;

    final clampedPage = newPage.clamp(0, book.totalPage);
    final derivedStatus = _deriveStatus(clampedPage, book.totalPage);

    final updated = book.copyWith(
      currentPage: clampedPage,
      status: derivedStatus,
      lastReadAt: DateTime.now(),
      dateFinished: derivedStatus == BookStatus.finished
          ? DateTime.now()
          : null,
    );

    repo.updateBook(updated);
    state = repo.getAllBooks();
    debugPrint('📖 updateBook: ${updated.title} now at page ${updated.currentPage}, state has ${state.length} books');
  }

  BookStatus _deriveStatus(int currentPage, int totalPages) {
    if (currentPage <= 0) return BookStatus.wantToRead;
    if (currentPage >= totalPages) return BookStatus.finished;
    return BookStatus.reading;
  }

  void updateStatus(String bookId, BookStatus status) {
    final repo = ref.read(bookRepositoryProviders);
    final book = repo.getBookById(bookId);
    if (book == null) return;

    int newCurrentPage = book.currentPage;
    if (status == BookStatus.finished) {
      newCurrentPage = book.totalPage;
    } else if (status == BookStatus.wantToRead) {
      newCurrentPage = 0;
    }

    final updated = book.copyWith(
      status: status,
      currentPage: newCurrentPage,
      dateFinished: status == BookStatus.finished ? DateTime.now() : null,
    );
    repo.updateBook(updated);
    AppToast.show('Marked as ${status.name}');
    state = repo.getAllBooks();
  }

  void updateCover(String bookId, String coverImagePath) {
    final repo = ref.read(bookRepositoryProviders);
    final book = repo.getBookById(bookId);
    if (book == null) return;
    final updated = book.copyWith(coverImagePath: coverImagePath);
    repo.updateBook(updated);
    state = repo.getAllBooks();
  }

  void editDetails(
    String bookId, {
    required String title,
    required String author,
    required int totalPages,
  }) {
    final repo = ref.read(bookRepositoryProviders);
    final book = repo.getBookById(bookId);
    if (book == null) return;
    final updated = book.copyWith(
      title: title,
      author: author,
      totalPage: totalPages,
    );
    repo.updateBook(updated);
    state = repo.getAllBooks();
  }

  void deleteBook(String bookId) {
    final linkedReminder = ref
        .read(bookReminderRepositoryProvider)
        .getAll()
        .where((r) => r.bookID == bookId)
        .toList();

    for(final reminder in linkedReminder){
      ref.read(notificationServicesProviders).cancel(reminder.notificationId);
      ref.read(bookReminderRepositoryProvider).delect(reminder.id);
    }
    ref.read(bookRepositoryProviders).deleteBook(bookId);
    state = ref.read(bookRepositoryProviders).getAllBooks();
    ref.invalidate(bookReminderProvider);
  }
}

final bookProviders = NotifierProvider<BookNotifier, List<Book>>(() {
  return BookNotifier();
});
