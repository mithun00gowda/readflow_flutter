import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/services_provider.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  String? _coverImagePath;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final book = Book(
      bookId: _uuid.v4(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      totalPage: int.parse(_pagesController.text.trim()),
      coverImagePath: _coverImagePath,
      dateAdded: DateTime.now(),
    );

    ref.read(bookProviders.notifier).addBook(book);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Book'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    _buildCoverPicker(),
                    const SizedBox(height: 28),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      icon: Icons.menu_book_outlined,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _authorController,
                      label: 'Author',
                      icon: Icons.person_outline,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pagesController,
                      label: 'Total Pages',
                      icon: Icons.description_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Sticky bottom action bar — submit always visible, no scrolling needed
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Add Book'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildCoverPicker() {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _coverImagePath != null
                ? Image.file(
              File(_coverImagePath!),
              width: 140,
              height: 190,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _coverPlaceholder(),
            )
                : _coverPlaceholder(),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _coverActionChip(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () async {
                  final path = await ref.read(imagePickerServiceProvider).pickFromCamera();
                  if (path != null) setState(() => _coverImagePath = path);
                },
              ),
              const SizedBox(width: 12),
              _coverActionChip(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () async {
                  final path = await ref.read(imagePickerServiceProvider).pickFromGallery();
                  if (path != null) setState(() => _coverImagePath = path);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 140,
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 40, color: AppColors.primary.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(
            'No cover yet',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _coverActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}