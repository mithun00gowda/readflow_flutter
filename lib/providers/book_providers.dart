import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/providers/repository_providers.dart';

class BookNotifier extends Notifier<List<Book>>{

  @override
  List<Book> build() {
    return ref.watch(bookRepositoryProviders).getAllBooks();
  }

  void addBook(Book book){
    ref.read(bookRepositoryProviders).addBook(book);
    state = ref.watch(bookRepositoryProviders).getAllBooks();
  }

  void updateBook(String bookId, int newPage){
    final repo = ref.read(bookRepositoryProviders);
    final book = repo.getBookById(bookId);
    if(book == null) return;
    final updated = book.copyWith(currentPage: newPage,lastReadAt: DateTime.now());
    repo.updateBook(updated);
    state = repo.getAllBooks();
  }
}

final bookProviders = NotifierProvider<BookNotifier, List<Book>>((){
 return BookNotifier();
});
