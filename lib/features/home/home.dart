import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/providers/book_providers.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final books = ref.watch(bookProviders);
    return ListView(
      children: books.map((b) => Text(b.title)).toList(),
    );
  }
}

