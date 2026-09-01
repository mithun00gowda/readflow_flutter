import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/repository_providers.dart';

import 'fake_book_repository.dart';

void main() {
  late ProviderContainer container;
  late FakeBookRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeBookRepository();
    container = ProviderContainer(
        overrides: [
          bookRepositoryProviders.overrideWithValue(fakeRepo),
        ]
    );
  });

  tearDown(() => container.dispose());

  Book buildTestBook(
      {int totalPages = 100, int currentPage = 0, BookStatus status = BookStatus
          .wantToRead}) {
    return Book(bookId: 'test-1',
        title: 'Test Book',
        author: 'Test Autor',
        totalPage: totalPages,
        currentPage: currentPage,
        status: status,
        dateAdded: DateTime.now());
  }
  
  group('BookNotifier.updatebook - auto status derivation', (){
    test('sets status is reading when page is between 0 and totalpage', () async{
      final book = buildTestBook(totalPages: 200);
      await fakeRepo.addBook(book);
      container.read(bookProviders.notifier).state = [book];
      container.read(bookProviders.notifier).updateBook('test-1', 50);
      final updated = container.read(bookProviders).first;
      expect(updated.status, equals(BookStatus.reading));
    });
    test('sets status to finished when page reaches total', () async{
      final book = buildTestBook(totalPages: 200);
      await fakeRepo.addBook(book);
      container.read(bookProviders.notifier).state = [book];
      container.read(bookProviders.notifier).updateBook('test-1', 200);
      final updated = container.read(bookProviders).first;
      expect(updated.status, equals(BookStatus.finished));
      expect(updated.dateFinished, isNotNull);
    });
    test('sets status back to wantread when page is 0', () async{
      final book = buildTestBook(totalPages: 200,currentPage: 50,status: BookStatus.reading);
      await fakeRepo.addBook(book);
      container.read(bookProviders.notifier).state = [book];
      container.read(bookProviders.notifier).updateBook('test-1', 0);
      final updated = container.read(bookProviders).first;
      expect(updated.status, equals(BookStatus.wantToRead));
    });
    
    test('un-finished a book if dragged backward from complete', () async{
      final book = buildTestBook(totalPages: 200,currentPage: 200,status: BookStatus.finished);
      await fakeRepo.addBook(book);
      container.read(bookProviders.notifier).state = [book];
      container.read(bookProviders.notifier).updateBook('test-1', 150);
      final updated = container.read(bookProviders).first;
      expect(updated.status, equals(BookStatus.reading));
      expect(updated.dateFinished, isNull);
    });
  });
}