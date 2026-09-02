import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/book.dart';
import '../../../providers/book_providers.dart';

class QuickUpdateButton extends ConsumerWidget {
  final Book book;
  const QuickUpdateButton({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final nextPage = (book.currentPage + 1).clamp(0, book.totalPage);
        ref.read(bookProviders.notifier).updateBook(book.bookId, nextPage);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3)],
        ),
        child: const Icon(Icons.add, size: 14, color: Colors.white),
      ),
    );
  }
}