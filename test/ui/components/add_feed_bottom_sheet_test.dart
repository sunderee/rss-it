import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/ui/components/bottom_sheet/add_feed_bottom_sheet.dart';

class MockFeedNotifier extends Mock implements FeedNotifier {}

void main() {
  group('AddFeedBottomSheet', () {
    late MockFeedNotifier mockNotifier;

    setUp(() {
      locator.clear();
      mockNotifier = MockFeedNotifier();
      locator.registerSingleton<FeedNotifier>(mockNotifier);
    });

    tearDown(() {
      locator.clear();
    });

    testWidgets('displays title and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => const AddFeedBottomSheet(),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Add RSS Feed'), findsOneWidget);
      expect(
        find.text(
          'Enter a valid RSS feed URL. We will validate it before adding it to your collection.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays text field for URL input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => const AddFeedBottomSheet(),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('RSS Feed URL'), findsOneWidget);
    });

    testWidgets('button is disabled initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => const AddFeedBottomSheet(),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('enables button when URL is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => const AddFeedBottomSheet(),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'https://example.com/rss.xml',
      );
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls addFeed when button is pressed', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.addFeed(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => const AddFeedBottomSheet(),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'https://example.com/rss.xml',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(
        () => mockNotifier.addFeed('https://example.com/rss.xml'),
      ).called(1);
    });

    testWidgets('trims URL before submitting', (WidgetTester tester) async {
      when(() => mockNotifier.addFeed(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => const AddFeedBottomSheet(),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        '  https://example.com/rss.xml  ',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(
        () => mockNotifier.addFeed('https://example.com/rss.xml'),
      ).called(1);
    });
  });
}
