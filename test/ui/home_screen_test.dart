import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/ui/home_screen.dart';

import '../helpers/mock_factories.dart';

class MockFeedNotifier extends Mock implements FeedNotifier {}

void main() {
  group('HomeScreen', () {
    late MockFeedNotifier mockNotifier;

    setUp(() {
      locator.clear();
      mockNotifier = MockFeedNotifier();
      locator.registerSingleton<FeedNotifier>(mockNotifier);
    });

    tearDown(() {
      locator.clear();
    });

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      when(() => mockNotifier.isLoading).thenReturn(false);
      when(() => mockNotifier.feeds).thenReturn([]);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('RSSit'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays add button in app bar', (WidgetTester tester) async {
      when(() => mockNotifier.isLoading).thenReturn(false);
      when(() => mockNotifier.feeds).thenReturn([]);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls getFeeds on init with forceRefresh', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.isLoading).thenReturn(false);
      when(() => mockNotifier.feeds).thenReturn([]);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      verify(() => mockNotifier.getFeeds(forceRefresh: true)).called(1);
    });

    testWidgets('displays loading indicator when loading', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.isLoading).thenReturn(true);
      when(() => mockNotifier.feeds).thenReturn([]);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no feeds', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.isLoading).thenReturn(false);
      when(() => mockNotifier.feeds).thenReturn([]);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Welcome to RSSit!'), findsOneWidget);
      expect(
        find.text(
          'Add your first RSS feed to get started with personalized news and updates from your favorite websites.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays feed list when feeds exist', (
      WidgetTester tester,
    ) async {
      final feeds = MockFactories.createFeedEntities(count: 3);

      when(() => mockNotifier.isLoading).thenReturn(false);
      when(() => mockNotifier.feeds).thenReturn(feeds);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('opens add feed bottom sheet when add button is tapped', (
      WidgetTester tester,
    ) async {
      when(() => mockNotifier.isLoading).thenReturn(false);
      when(() => mockNotifier.feeds).thenReturn([]);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Add RSS Feed'), findsOneWidget);
    });

    testWidgets('refreshes feeds on pull to refresh', (
      WidgetTester tester,
    ) async {
      final feeds = MockFactories.createFeedEntities(count: 2);

      when(() => mockNotifier.isLoading).thenReturn(false);
      when(() => mockNotifier.feeds).thenReturn(feeds);
      when(
        () => mockNotifier.getFeeds(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      await refreshIndicator.onRefresh();
      await tester.pumpAndSettle();

      verify(() => mockNotifier.getFeeds()).called(1);
    });
  });
}
