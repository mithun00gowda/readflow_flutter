import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/core/widgets/app_toast.dart';
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
  double? _sliderValue;
  bool _sessionActive = false;
  int _elapsedSeconds = 0; // persists even after the timer is stopped
  Timer? _ticker;

  void _toggleSession() {
    if (_sessionActive) {
      _ticker?.cancel();
      setState(() => _sessionActive = false);
      // _elapsedSeconds is intentionally NOT reset here — keep it until save/discard
    } else {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsedSeconds++);
      });
      setState(() => _sessionActive = true);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }


  String get _formattedElapsed {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
@override
  void initState() {
    super.initState();
  }
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
            _buildSessionTimer(),
            const SizedBox(height: 24),
            _buildCircularSlider(book),
            const SizedBox(height: 20),
            _buildQuickUpdateRow(book),
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
                  final duration = _elapsedSeconds > 0 ? (_elapsedSeconds / 60).ceil() : null;

                  ref.read(bookProviders.notifier).updateBook(book.bookId, toPage);
                  ref.read(readingLogsProvider.notifier).logProgress(
                    book.bookId, fromPage, toPage,
                    sessionDurationMinutes: duration,
                  );

                  _ticker?.cancel();
                  setState(() {
                    _sessionActive = false;
                    _elapsedSeconds = 0; // NOW it's safe to reset — the value has been consumed/logged
                  });
                  AppToast.show('Progress saved');
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
                  errorBuilder: (_, _, _) => _coverPlaceholder(),
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
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.menu_book_outlined, size: 32, color: AppColors.primary.withValues(alpha: 0.5)),
    );
  }

  Widget _buildStatusSelector(Book book) {
    return SegmentedButton<BookStatus>(
      segments: const [
        ButtonSegment(value: BookStatus.wantToRead, label: Text('Want to Read',style: TextStyle(fontSize: 10),), icon: Icon(Icons.bookmark_outline, size: 16)),
        ButtonSegment(value: BookStatus.reading, label: Text('Reading',style: TextStyle(fontSize: 10),), icon: Icon(Icons.menu_book_outlined, size: 16)),
        ButtonSegment(value: BookStatus.finished, label: Text('Finished',style: TextStyle(fontSize: 10),), icon: Icon(Icons.check_circle_outline, size: 16)),
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
            trackColor: AppColors.primary.withValues(alpha: 0.12),
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
                AppToast.show('Cover updated');
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
                maxLength: 3,
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
                  onPressed: () async{
                    if (!formKey.currentState!.validate()) return;
                    ref.read(bookProviders.notifier).editDetails(
                      book.bookId,
                      title: titleController.text.trim(),
                      author: authorController.text.trim(),
                      totalPages: int.parse(pagesController.text.trim()),
                    );
                    AppToast.show('Book details updated');
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
              AppToast.show('Book deleted', type: ToastType.error);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
  Widget _buildSessionTimer() {
    return GestureDetector(
      onTap: _toggleSession,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _sessionActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_sessionActive)
              _PulsingDot()
            else
              Icon(Icons.play_circle_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              _sessionActive ? 'Reading · $_formattedElapsed' : 'Start Reading Session',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _sessionActive ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuickUpdateRow(Book book) {
    final currentValue = _sliderValue!.round();

    return Column(
      children: [
        // Stepper: -10 / -1 / [type page] / +1 / +10
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stepButton(icon: Icons.remove, onTap: () => _adjustPage(-10, book), label: '-10'),
            _stepButton(icon: Icons.remove, onTap: () => _adjustPage(-1, book), label: '-1'),
            _buildPageInput(book),
            _stepButton(icon: Icons.add, onTap: () => _adjustPage(1, book), label: '+1'),
            _stepButton(icon: Icons.add, onTap: () => _adjustPage(10, book), label: '+10'),
          ],
        ),
        const SizedBox(height: 14),
        // Quick jump chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _jumpChip('+25 pages', () => _adjustPage(25, book)),
            const SizedBox(width: 8),
            _jumpChip('Mark as finished', () => setState(() => _sliderValue = book.totalPage.toDouble())),
          ],
        ),
      ],
    );
  }

  void _adjustPage(int delta, Book book) {
    final newValue = (_sliderValue!.round() + delta).clamp(0, book.totalPage);
    setState(() => _sliderValue = newValue.toDouble());
  }

  Widget _stepButton({required IconData icon, required VoidCallback onTap, required String label}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildPageInput(Book book) {
    return GestureDetector(
      onTap: () => _showPageInputDialog(book),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_sliderValue!.round()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _jumpChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
      ),
    );
  }

  void _showPageInputDialog(Book book) {
    final controller = TextEditingController(text: _sliderValue!.round().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Page number (0–${book.totalPage})'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null) {
                setState(() => _sliderValue = page.clamp(0, book.totalPage).toDouble());
              }
              Navigator.pop(context);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}