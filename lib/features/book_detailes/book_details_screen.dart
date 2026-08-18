import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/reading_logs_providers.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  final String bookId;
  const BookDetailsScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  late int _sliderValue;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(bookProviders);
    final book = books.firstWhere((b) => (b.bookId == widget.bookId));

    if (!_initialized) {
      _sliderValue = book.currentPage;
      _initialized = true;
    }
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: book.progress),
            const SizedBox(height: 16),
            Text('Page $_sliderValue of ${book.totalPage}'),
            Slider(
              value: _sliderValue.toDouble(),
              min: 0,
              max: book.totalPage.toDouble(),
              divisions: book.totalPage,
              label: '$_sliderValue',
              onChanged: (v) => setState(() => _sliderValue = v.round()),
            ),
            ElevatedButton(
              onPressed: _sliderValue == book.currentPage
                  ? null
                  : () {
                      final fromPage = book.currentPage;
                      ref
                          .read(bookProviders.notifier)
                          .updateBook(book.bookId, _sliderValue);
                      ref
                          .read(readingLogsProvider.notifier)
                          .logProgress(book.bookId, fromPage, _sliderValue);
                    },
              child: Text('Update Progress'),
            ),
          ],
        ),
      ),
    );
  }
}
