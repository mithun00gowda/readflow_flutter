import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      bookId: _uuid.v4(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      totalPage: int.parse(_pagesController.text.trim()),
      coverImagePath: _coverImagePath,
      dateAdded: DateTime.now(),
    );
    ref.read(bookProviders.notifier).addBook(book);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Add Book')),
      body: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requied' : null,
                  ),
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Author'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requied' : null,
                  ),
                  TextFormField(
                    controller: _pagesController,
                    decoration: const InputDecoration(labelText: 'Total Pages'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Book'),
                  ),
                  _buildCoverPicker()
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildCoverPicker(){
    return Column(
      children: [
      if(_coverImagePath != null)
          Image.file(File(_coverImagePath!), height: 120,)
        else
          Container(
            height: 120,
            color: Colors.grey.shade200,
            child: const Icon(Icons.book,size: 48,),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              TextButton.icon(onPressed: () async{
                final path = await ref.read(imagePickerServiceProvider).pickFromCamera();
                if(path != null) setState(() => _coverImagePath = path);
              }, label: Text('Camera'),icon: Icon(Icons.camera),),
            TextButton.icon(onPressed: () async{
              final path = await ref.read(imagePickerServiceProvider).pickFromGallery();
              if(path != null) setState(() => _coverImagePath = path);
            }, label: Text('Gallery'),icon: Icon(Icons.photo_library),)
          ],
        )
      ],
    );
  }
}


