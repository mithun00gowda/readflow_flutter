import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readflow/features/home/widgets/book_card.dart';

void main() {
  Widget warpInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('display title, author, and page info', ((tester) async {
    var tapped = false;
    await tester.pumpWidget(
      warpInApp(
        BookCard(
          title: 'Dune',
          author: 'Frank Harbert',
          progress: 0.5,
          currentPage: 200,
          totalPages: 400,
          coverImagePath: null,
          onTap: () => tapped = true,
        ),
      ),
    );
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Frank Harbert'), findsOneWidget);
    expect(find.text('Page 200 of 400 - 50%'), findsOneWidget);
  }));

  testWidgets('Show fallback icon when no cover image is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      warpInApp(
        BookCard(
          title: 'test book',
          author: 'test author',
          progress: 0.0,
          currentPage: 0,
          totalPages: 100,
          coverImagePath: null,
          onTap: () {},
        ),
      ),
    );
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
  });

  testWidgets('calls onTap when the card is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      warpInApp(
        BookCard(
          title: 'test',
          author: 'Test autor',
          progress: 0.5,
          currentPage: 100,
          totalPages: 200,
          coverImagePath: null,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.tap(find.byType(BookCard));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('progress bar reflects the given progress value', (tester) async {
    await tester.pumpWidget(
      warpInApp(
        BookCard(
          title: 'test',
          author: 'test author',
          progress: 0.75,
          currentPage: 75,
          totalPages: 100,
          coverImagePath: null,
          onTap: () {},
        ),
      ),
    );
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, equals(0.75));
  });
}
