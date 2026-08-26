import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/reading_logs_providers.dart';
import 'package:readflow/providers/services_provider.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  final String bookId;
  const BookDetailsScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  double? _sliderValue; // null until first synced from book data

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(bookProviders);
    final book = books.firstWhereOrNull((b) => b.bookId == widget.bookId);

    if (book == null) {
      // Book was deleted (e.g. by this screen's own delete action, mid-navigation)
      // — show a brief neutral state instead of crashing.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _sliderValue ??= book.currentPage.toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(book.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSheet(context, book),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, book),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCoverAndInfo(book),
            const SizedBox(height: 24),
            _buildStatusSelector(book),
            const SizedBox(height: 24),
            _buildCircularSlider(book),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sliderValue!.round() == book.currentPage
                    ? null
                    : () {
                  final fromPage = book.currentPage;
                  final toPage = _sliderValue!.round();
                  ref.read(bookProviders.notifier).updateBook(book.bookId, toPage);
                  ref
                      .read(readingLogsProvider.notifier)
                      .logProgress(book.bookId, fromPage, toPage);
                },
                child: const Text('Update Progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverAndInfo(Book book) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showCoverPicker(book),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: book.coverImagePath != null
                    ? Image.file(
                  File(book.coverImagePath!),
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _coverPlaceholder(),
                )
                    : _coverPlaceholder(),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(book.author, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Text(
                '${book.totalPage} pages total',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.menu_book_outlined, size: 32, color: AppColors.primary.withOpacity(0.5)),
    );
  }

  Widget _buildStatusSelector(Book book) {
    return SegmentedButton<BookStatus>(
      segments: const [
        ButtonSegment(value: BookStatus.wantToRead, label: Text('Want to Read'), icon: Icon(Icons.bookmark_outline, size: 16)),
        ButtonSegment(value: BookStatus.reading, label: Text('Reading'), icon: Icon(Icons.menu_book_outlined, size: 16)),
        ButtonSegment(value: BookStatus.finished, label: Text('Finished'), icon: Icon(Icons.check_circle_outline, size: 16)),
      ],
      selected: {book.status},
      onSelectionChanged: (selected) {
        ref.read(bookProviders.notifier).updateStatus(book.bookId, selected.first);
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCircularSlider(Book book) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SleekCircularSlider(
        min: 0,
        max: book.totalPage.toDouble() == 0 ? 1 : book.totalPage.toDouble(),
        initialValue: _sliderValue!.clamp(0, book.totalPage.toDouble()),
        onChange: (value) => setState(() => _sliderValue = value),
        appearance: CircularSliderAppearance(
          size: 220,
          angleRange: 280,
          startAngle: 130,
          customColors: CustomSliderColors(
            progressBarColor: AppColors.primary,
            trackColor: AppColors.primary.withOpacity(0.12),
            dotColor: AppColors.primary,
          ),
          customWidths: CustomSliderWidths(progressBarWidth: 14, trackWidth: 14, handlerSize: 10),
          infoProperties: InfoProperties(
            mainLabelStyle: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            modifier: (value) => '${value.round()}',
            bottomLabelText: 'of ${book.totalPage} pages',
            bottomLabelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  void _showCoverPicker(Book book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final path = await ref.read(imagePickerServiceProvider).pickFromCamera();
                if (path != null) ref.read(bookProviders.notifier).updateCover(book.bookId, path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final path = await ref.read(imagePickerServiceProvider).pickFromGallery();
                if (path != null) ref.read(bookProviders.notifier).updateCover(book.bookId, path);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, Book book) {
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    final pagesController = TextEditingController(text: book.totalPage.toString());
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pagesController,
                decoration: const InputDecoration(labelText: 'Total Pages'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    ref.read(bookProviders.notifier).editDetails(
                      book.bookId,
                      title: titleController.text.trim(),
                      author: authorController.text.trim(),
                      totalPages: int.parse(pagesController.text.trim()),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this book?'),
        content: Text('"${book.title}" and its reading history will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close screen, back to Home — unmount before mutating state
              ref.read(bookProviders.notifier).deleteBook(book.bookId);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}