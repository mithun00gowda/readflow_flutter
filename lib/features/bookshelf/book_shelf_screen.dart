import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/features/book_detailes/book_details_screen.dart';
import 'package:readflow/providers/book_providers.dart';

import 'widget/quick_update_button.dart';

class BookShelfScreen extends ConsumerStatefulWidget {
  const BookShelfScreen({super.key});

  @override
  ConsumerState<BookShelfScreen> createState() => _BookShelfScreenState();
}

class _BookShelfScreenState extends ConsumerState<BookShelfScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Want to Read', 'Reading', 'Finished'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(bookProviders);
    final grouped = [
      books.where((b) => b.status == BookStatus.wantToRead).toList(),
      books.where((b) => b.status == BookStatus.reading).toList(),
      books.where((b) => b.status == BookStatus.finished).toList(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Bookshelf'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: grouped.map((list) => _ShelfRow(books: list)).toList(),
      ),
    );
  }
}

class _ShelfRow extends StatelessWidget {
  final List<Book> books;
  const _ShelfRow({required this.books});

  static const _shelfWood = Color(0xFFA47551);

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shelves, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('Nothing on this shelf yet', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => _ShelfBookCard(book: books[index]),
    );
  }
}

class _ShelfBookCard extends StatelessWidget {
  final Book book;
  const _ShelfBookCard({required this.book});

  static const _shelfWood = Color(0xFFA47551);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.bookId)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Book cover — spine accent on the left edge for a "standing book" feel
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: book.coverImagePath != null
                      ? Image.file(
                    File(book.coverImagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _coverPlaceholder(),
                  )
                      : _coverPlaceholder(),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 4, color: Colors.black.withOpacity(0.18)),
                ),
                if (book.status == BookStatus.reading)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: QuickUpdateButton(book: book),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          if (book.status == BookStatus.reading)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${(book.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(height: 6),
          // The wooden shelf ledge each "book" rests on
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: _shelfWood,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: _shelfWood.withOpacity(0.4),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      alignment: Alignment.center,
      child: Icon(Icons.menu_book_outlined, color: AppColors.primary.withOpacity(0.5), size: 28),
    );
  }
}

