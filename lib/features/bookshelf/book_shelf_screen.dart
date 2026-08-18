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
    final wanttoreadbooks = books.where((b) => b.status == BookStatus.wantToRead).toList();
    final readingbooks = books.where((b) => b.status == BookStatus.reading).toList();
    final finishedbooks = books.where((b) => b.status == BookStatus.finished).toList();

    return DefaultTabController(
      initialIndex: 0,
      length: BookStatus.values.length,
      child: Scaffold(
        appBar: AppBar(title: Text('Book Shelf'),
          bottom: TabBar(tabs: <Widget>[
            ...List.generate(BookStatus.values.length, (i) => Tab(text: BookStatus.values[i].toString(),))
          ]),
        ),
        body: Padding(padding: EdgeInsets.all(16),child: TabBarView(children: <Widget>[
          ListView.builder(
              itemCount: wanttoreadbooks.length,
              itemBuilder:(BuildContext context, index){
                final book = wanttoreadbooks[index];
                return ListTile(title: Text(book.title),);
              }),
          ListView.builder(
              itemCount: readingbooks.length,
              itemBuilder:(BuildContext context, index){
                final book = readingbooks[index];
                return ListTile(title: Text(book.title),);
              }),
          ListView.builder(
              itemCount: finishedbooks.length,
              itemBuilder:(BuildContext context, index){
                final book = finishedbooks[index];
                return ListTile(title: Text(book.title),);
              })
        ])),
      ),
    );
  }
}
