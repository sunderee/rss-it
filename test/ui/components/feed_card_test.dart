import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/ui/components/feed_card.dart';

import '../../helpers/mock_factories.dart';

class MockFeedNotifier extends Mock implements FeedNotifier {}

void main() {
  group('FeedCard', () {
    late MockFeedNotifier mockNotifier;

    setUp(() {
      locator.clear();
      mockNotifier = MockFeedNotifier();
      locator.registerSingleton<FeedNotifier>(mockNotifier);
    });

    tearDown(() {
      locator.clear();
    });

    testWidgets('displays feed title', (WidgetTester tester) async {
      final feed = MockFactories.createFeedEntity(title: 'Test Feed Title');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      expect(find.text('Test Feed Title'), findsOneWidget);
    });

    testWidgets('displays feed description when available', (
      WidgetTester tester,
    ) async {
      final feed = MockFactories.createFeedEntity(
        description: 'Test Feed Description',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      expect(find.text('Test Feed Description'), findsOneWidget);
    });

    testWidgets('does not display description when null', (
      WidgetTester tester,
    ) async {
      // Create feed with explicit null description (not using default)
      final feed = FeedEntity(
        id: null,
        url: 'https://example.com/rss.xml',
        title: 'Test Feed',
        description: null, // Explicitly null
        thumbnailURL: null,
        addedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      // When description is null, subtitle should not be displayed
      expect(find.text('Test Feed Description'), findsNothing);
      // Verify that the ListTile exists but has no subtitle text
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.subtitle, isNull);
    });

    testWidgets('navigates to feed screen on tap', (WidgetTester tester) async {
      final feed = MockFactories.createFeedEntity(id: 1, title: 'Test Feed');

      when(() => mockNotifier.isLoadingFeedItems).thenReturn(false);
      when(() => mockNotifier.feedItems).thenReturn([]);
      when(() => mockNotifier.loadFeedItems(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // After navigation, FeedScreen should be displayed with the feed title
      expect(find.text('Test Feed'), findsWidgets);
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('shows popup menu', (WidgetTester tester) async {
      final feed = MockFactories.createFeedEntity(id: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      // PopupMenuButton is generic, so find by icon instead
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('shows delete dialog when delete is selected', (
      WidgetTester tester,
    ) async {
      final feed = MockFactories.createFeedEntity(id: 1);

      when(() => mockNotifier.removeFeed(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete feed'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this feed?'),
        findsOneWidget,
      );
    });

    testWidgets('shows feed info dialog when info is selected', (
      WidgetTester tester,
    ) async {
      final feed = MockFactories.createFeedEntity(
        id: 1,
        title: 'Test Feed',
        description: 'Test Description',
        url: 'https://example.com/rss.xml',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();

      expect(find.text('Test Feed'), findsWidgets);
      expect(find.text('https://example.com/rss.xml'), findsOneWidget);
    });

    testWidgets('does not show delete dialog when feed id is null', (
      WidgetTester tester,
    ) async {
      final feed = MockFactories.createFeedEntity(id: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedCard(feed: feed)),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete feed'), findsNothing);
    });
  });
}
