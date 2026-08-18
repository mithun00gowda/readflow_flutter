import 'package:hive/hive.dart';
import 'package:readflow/data/models/book.dart';

abstract class BookRepository {
  List<Book> getAllBooks();

  List<Book> getBookByStatus(BookStatus status);

  Book? getBookById(String id);

  Future<void> addBook(Book book);

  Future<void> updateBook(Book book);

  Future<void> deleteBook(String id);
}

class HiveBookRepository implements BookRepository {
  final Box<Book> _box;

  HiveBookRepository(this._box);

  @override
  List<Book> getAllBooks() => _box.values.toList();

  @override
  List<Book> getBookByStatus(BookStatus status) =>
      _box.values.where((b) => b.status == status).toList();

  @override
  Book? getBookById(String id) =>
      _box.values.where((b) => b.bookId == id).firstOrNull;

  @override
  Future<void> addBook(Book book) => _box.put(book.bookId, book);

  @override
  Future<void> updateBook(Book book) => _box.put(book.bookId, book);

  @override
  Future<void> deleteBook(String id) => _box.delete(id);
}
