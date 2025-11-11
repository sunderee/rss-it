import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/ui/feed_screen.dart';

import '../helpers/mock_factories.dart';

class MockFeedNotifier extends Mock implements FeedNotifier {}

void main() {
  group('FeedScreen', () {
    late MockFeedNotifier mockNotifier;

    setUp(() {
      locator.clear();
      mockNotifier = MockFeedNotifier();
      locator.registerSingleton<FeedNotifier>(mockNotifier);
    });

    tearDown(() {
      locator.clear();
    });

    testWidgets('displays app bar with feed title', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.isLoadingFeedItems).thenReturn(false);
      when(() => mockNotifier.feedItems).thenReturn([]);
      when(() => mockNotifier.loadFeedItems(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        const MaterialApp(home: FeedScreen(feedID: 1, title: 'Test Feed')),
      );

      expect(find.text('Test Feed'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('calls loadFeedItems on init', (WidgetTester tester) async {
      when(() => mockNotifier.isLoadingFeedItems).thenReturn(false);
      when(() => mockNotifier.feedItems).thenReturn([]);
      when(() => mockNotifier.loadFeedItems(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        const MaterialApp(home: FeedScreen(feedID: 1, title: 'Test Feed')),
      );

      await tester.pump();

      verify(() => mockNotifier.loadFeedItems(1)).called(1);
    });

    testWidgets('displays loading indicator when loading', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.isLoadingFeedItems).thenReturn(true);
      when(() => mockNotifier.feedItems).thenReturn([]);
      when(() => mockNotifier.loadFeedItems(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        const MaterialApp(home: FeedScreen(feedID: 1, title: 'Test Feed')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty message when no feed items', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.isLoadingFeedItems).thenReturn(false);
      when(() => mockNotifier.feedItems).thenReturn([]);
      when(() => mockNotifier.loadFeedItems(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        const MaterialApp(home: FeedScreen(feedID: 1, title: 'Test Feed')),
      );

      expect(find.text('No feed items found'), findsOneWidget);
    });

    testWidgets('displays feed items list when items exist', (
      WidgetTester tester,
    ) async {
      final items = MockFactories.createFeedItemEntities(feedID: 1, count: 3);

      when(() => mockNotifier.isLoadingFeedItems).thenReturn(false);
      when(() => mockNotifier.feedItems).thenReturn(items);
      when(() => mockNotifier.loadFeedItems(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        const MaterialApp(home: FeedScreen(feedID: 1, title: 'Test Feed')),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
