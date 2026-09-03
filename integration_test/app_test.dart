// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/data/models/reading_log.dart';
import 'package:readflow/data/models/reminder_settings.dart';
import 'package:readflow/data/models/book_reminder.dart';
import 'package:readflow/features/root_nav.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    debugPrint('🔧 setUp: initializing Hive...');
    await Hive.initFlutter('integration_test_hive');
    Hive.registerAdapter(BookStatusAdapter());
    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(ReadingLogAdapter());
    Hive.registerAdapter(ReminderSettingsAdapter());
    Hive.registerAdapter(BookReminderAdapter());

    await Hive.openBox<Book>('books');
    await Hive.openBox<ReadingLog>('reading_log');
    await Hive.openBox<ReminderSettings>('reminder_settings');
    await Hive.openBox<BookReminder>('book_reminder');
    debugPrint('🔧 setUp: Hive ready');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    debugPrint('🔧 tearDown: Hive wiped');
  });

  testWidgets('add a book, see it on Home, update its progress', (tester) async {
    debugPrint('▶️ pumping widget...');
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: RootNav())));
    debugPrint('✅ pumpWidget (first frame) done');

    // Use bounded pump() calls instead of pumpAndSettle() here, so we can see
    // exactly how many frames it takes (or if it never stabilizes) at startup.
    for (var i = 1; i <= 5; i++) {
      await tester.pump(const Duration(seconds: 1));
      debugPrint('✅ startup pump #$i (1s) done');
    }

    debugPrint('▶️ checking for empty state text...');
    expect(find.text('Your shelf is empty'), findsOneWidget);
    debugPrint('✅ empty state confirmed');

    debugPrint('▶️ tapping FAB...');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(seconds: 1));
    debugPrint('✅ FAB tapped, one frame pumped');

    for (var i = 1; i <= 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('✅ post-FAB pump #$i done');
    }

    debugPrint('▶️ entering form text...');
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Dune');
    await tester.enterText(find.widgetWithText(TextFormField, 'Author'), 'Frank Herbert');
    await tester.enterText(find.widgetWithText(TextFormField, 'Total Pages'), '412');
    debugPrint('✅ form filled');

    debugPrint('▶️ tapping Add Book...');
    await tester.tap(find.text('Add Book'));
    for (var i = 1; i <= 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('✅ post-AddBook pump #$i done');
    }

    debugPrint('▶️ checking Home shows the new book...');
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Your shelf is empty'), findsNothing);
    debugPrint('✅ book visible on Home');

    debugPrint('▶️ tapping the book card...');
    await tester.tap(find.text('Dune'));
    for (var i = 1; i <= 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('✅ post-tap-book pump #$i done');
    }

    debugPrint('▶️ tapping +10 stepper...');
    await tester.tap(find.text('+10'));
    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('✅ +10 tapped');

    debugPrint('▶️ tapping Update Progress...');
    await tester.tap(find.text('Update Progress'));
    for (var i = 1; i <= 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('✅ post-update pump #$i done');
    }

    debugPrint('▶️ navigating back...');
    await tester.pageBack();
    for (var i = 1; i <= 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('✅ post-back pump #$i done');
    }

    debugPrint('▶️ final assertion...');
    expect(find.textContaining('Page 10 of 412'), findsOneWidget);
    debugPrint('✅ TEST COMPLETE');
  });
}