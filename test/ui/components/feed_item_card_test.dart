import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/ui/components/feed_item_card.dart';

import '../../helpers/mock_factories.dart';

class MockFeedNotifier extends Mock implements FeedNotifier {}

void main() {
  group('FeedItemCard', () {
    late MockFeedNotifier mockNotifier;

    setUp(() {
      locator.clear();
      mockNotifier = MockFeedNotifier();
      locator.registerSingleton<FeedNotifier>(mockNotifier);
    });

    tearDown(() {
      locator.clear();
    });
    testWidgets('displays feed item title', (WidgetTester tester) async {
      final feedItem = MockFactories.createFeedItemEntity(
        title: 'Test Article Title',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedItemCard(feedItem: feedItem)),
        ),
      );

      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets('displays feed item description when available', (
      WidgetTester tester,
    ) async {
      final feedItem = MockFactories.createFeedItemEntity(
        description: 'Test Article Description',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedItemCard(feedItem: feedItem)),
        ),
      );

      expect(find.text('Test Article Description'), findsOneWidget);
    });

    testWidgets('does not display description when null', (
      WidgetTester tester,
    ) async {
      // Create feed item with explicit null description (not using default)
      final feedItem = FeedItemEntity(
        id: null,
        feedID: 1,
        link: 'https://example.com/article/1',
        title: 'Test Article',
        description: null, // Explicitly null
        imageURL: null,
        publishedAt: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedItemCard(feedItem: feedItem)),
        ),
      );

      expect(find.text('Test Article Description'), findsNothing);
      // Verify that the ListTile exists but has no subtitle text
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.subtitle, isNull);
    });

    testWidgets('does not display description when empty', (
      WidgetTester tester,
    ) async {
      final feedItem = MockFactories.createFeedItemEntity(description: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedItemCard(feedItem: feedItem)),
        ),
      );

      expect(find.text(''), findsNothing);
    });

    testWidgets('renders as Card with ListTile', (WidgetTester tester) async {
      final feedItem = MockFactories.createFeedItemEntity();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedItemCard(feedItem: feedItem)),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
