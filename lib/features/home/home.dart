import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/features/add_book/add_book_screen.dart';
import 'package:readflow/features/book_detailes/book_details_screen.dart';
import 'package:readflow/features/bookshelf/book_shelf_screen.dart';
import 'package:readflow/features/settings/settings_screen.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/services_provider.dart';
import 'package:uuid/uuid.dart';


final _uuid = Uuid();
class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(bookProviders);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReadFlow'),
        leading: IconButton(
          onPressed: () async {
            // await ref.read(notificationServicesProviders).showImmediateNotification(
            //   id: 0,
            //   title: 'ReadTrack',
            //   body: 'Reminder test',
            // );
            final testTime = DateTime.now().add(const Duration(minutes: 1));
            await ref.read(notificationServicesProviders).scheduleDailyReminder(
              id: 0,
              hour: testTime.hour,
              minute: testTime.minute,
              title: 'Test',
              body: 'ReadTrack reminder test',
            );
            debugPrint('${TimeOfDay.now().hour},${TimeOfDay.now().minute + 1}' );
          },
          icon: Icon(Icons.alarm),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookShelfScreen()),
            ),
            icon: Icon(Icons.keyboard_arrow_right_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
            icon: Icon(Icons.settings),
          ),

        ],
      ),
      body: books.isEmpty
          ? const Center(child: Text('No books yet - tap + to add one'))
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.author} * ${(book.progress * 100).toStringAsFixed(0)}%',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookDetailsScreen(bookId: book.bookId),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => AddBookScreen())),
        child: Icon(Icons.add),
      ),
    );
  }
}
