import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/features/bookshelf/widget/quick_update_button.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/repository_providers.dart';

import '../../../fake/fake_book_repository.dart';

void main() {
  late FakeBookRepository fakeRepo;
  Book buildBook() {
    return Book(
      bookId: 'test-01',
      title: 'test-book',
      author: 'test-author',
      totalPage: 200,
      currentPage: 100,
      status: BookStatus.reading,
      dateAdded: DateTime.now(),
    );
  }

  setUp(() {
    fakeRepo = FakeBookRepository();
  });

  testWidgets('tapping the button increments the current page by 1', (
    tester,
  ) async {
    final book = buildBook();
    await fakeRepo.addBook(book);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookRepositoryProviders.overrideWithValue(fakeRepo)],
        child: MaterialApp(
          home: Scaffold(body: QuickUpdateButton(book: book)),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuickUpdateButton)),
    );
    container.read(bookProviders.notifier).state = [book];

    await tester.tap(find.byType(QuickUpdateButton));
    await tester.pump();
    final updatedBook = container.read(bookProviders).first;
    expect(updatedBook.currentPage, equals(101));
  });

  testWidgets('does not exceed totalPage when tapped at max', (tester) async {
    final book = Book(
      bookId: 'test-1',
      title: 'test-book',
      author: 'test-author',
      totalPage: 50,
      dateAdded: DateTime.now(),
      currentPage: 50,
      status: BookStatus.finished,
    );

    await fakeRepo.addBook(book);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookRepositoryProviders.overrideWithValue(fakeRepo)],
        child: MaterialApp(
          home: Scaffold(body: QuickUpdateButton(book: book)),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuickUpdateButton)),
    );
    container.read(bookProviders.notifier).state = [book];

    await tester.tap(find.byType(QuickUpdateButton));
    await tester.pump();
    final updatedBook = container.read(bookProviders).first;
    expect(updatedBook.currentPage, equals(50));
  });
}
