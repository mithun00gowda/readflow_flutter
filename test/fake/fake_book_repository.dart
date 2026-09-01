import 'package:readflow/data/models/book.dart';
import 'package:readflow/data/repositories/book_repository.dart';

class FakeBookRepository implements BookRepository {
  final Map<String, Book> _store = {};
  @override
  List<Book> getAllBooks() => _store.values.toList();

  @override
  List<Book> getBookByStatus(BookStatus status) => _store.values.where((b) => b.status == status).toList();

  @override
  Book? getBookById(String id) => _store[id];

  @override
  Future<void> addBook(Book book) async => _store[book.bookId] = book;

  @override
  Future<void> updateBook(Book book) async => _store[book.bookId] = book;

  @override
  Future<void> deleteBook(String id) async => _store.remove(id);
}