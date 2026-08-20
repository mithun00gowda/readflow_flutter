import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
enum BookStatus {
  @HiveField(0)
  wantToRead,
  @HiveField(1)
  reading,
  @HiveField(2)
  finished }


@HiveType(typeId: 1)
class Book extends HiveObject {
  @HiveField(0)
  final String bookId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String author;
  @HiveField(3)
  final String? coverImagePath;
  @HiveField(4)
  final int totalPage;
  @HiveField(5)
  final int currentPage;
  @HiveField(6)
  final BookStatus status;
  @HiveField(7)
  final DateTime dateAdded;
  @HiveField(8)
  final DateTime? dateFinished;
  @HiveField(9)
  final DateTime? lastReadAt;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    this.coverImagePath,
    required this.totalPage,
    this.currentPage = 0,
    this.status = BookStatus.wantToRead,
    required this.dateAdded,
    this.dateFinished,
    this.lastReadAt,
  });

  double get progress => totalPage == 0 ? 0 : currentPage / totalPage;

  Book copyWith({
    int? currentPage,
    BookStatus? status,
    DateTime? dateFinished,
    DateTime? lastReadAt,
  }) {
    return Book(
      bookId: bookId,
      title: title,
      author: author,
        coverImagePath: coverImagePath,
      totalPage: totalPage,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      dateAdded: dateAdded,
      dateFinished: dateFinished ?? this.dateFinished,
      lastReadAt: lastReadAt ?? this.lastReadAt
    );
  }
}
