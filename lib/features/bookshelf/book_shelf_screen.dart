import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/providers/book_providers.dart';

class BookShelfScreen extends ConsumerStatefulWidget {
  const BookShelfScreen({super.key});

  @override
  ConsumerState<BookShelfScreen> createState() => _BookShelfScreenState();
}

class _BookShelfScreenState extends ConsumerState<BookShelfScreen> {
  @override
  Widget build(BuildContext context) {
    final books = ref.watch(bookProviders);
    final wantToReadBooks = books.where((b) => b.status == BookStatus.wantToRead).toList();
    final readingBooks = books.where((b) => b.status == BookStatus.reading).toList();
    final finishedBooks = books.where((b) => b.status == BookStatus.finished).toList();
    final List<String> status = ['WantToRead','Reading','Finished'];
    return DefaultTabController(
      initialIndex: 0,
      length: BookStatus.values.length,
      child: Scaffold(
        appBar: AppBar(title: Text('Book Shelf'),
          bottom: TabBar(tabs: <Widget>[
            ...List.generate(status.length, (i) => Tab(text: status[i].toString(),))
          ]),
        ),
        body: Padding(padding: EdgeInsets.all(16),child: TabBarView(children: <Widget>[
          ListView.builder(
              itemCount: wantToReadBooks.length,
              itemBuilder:(BuildContext context, index){
                final book = wantToReadBooks[index];
                return ListTile(title: Text(book.title),);
              }),
          ListView.builder(
              itemCount: readingBooks.length,
              itemBuilder:(BuildContext context, index){
                final book = readingBooks[index];
                return ListTile(title: Text(book.title),);
              }),
          ListView.builder(
              itemCount: finishedBooks.length,
              itemBuilder:(BuildContext context, index){
                final book = finishedBooks[index];
                return ListTile(title: Text(book.title),);
              })
        ])),
      ),
    );
  }
}
