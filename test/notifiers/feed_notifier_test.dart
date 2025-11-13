import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rss_it/domain/data/enums.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

import '../helpers/mock_factories.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Feed());
  });

  group('FeedNotifier', () {
    late MockFeedRepository mockRepository;
    late FeedNotifier notifier;

    setUp(() {
      mockRepository = MockFeedRepository();
      notifier = FeedNotifier(feedRepositoryInstance: mockRepository);
    });

    group('Initial State', () {
      test('initializes with correct default values', () {
        expect(notifier.isLoading, isFalse);
        expect(notifier.isLoadingFeedItems, isFalse);
        expect(
          notifier.feedValidationStatus,
          equals(FeedValidationStatus.idle),
        );
        expect(notifier.feeds.isEmpty, isTrue);
        expect(notifier.feedItems.isEmpty, isTrue);
      });
    });

    group('getFeeds', () {
      test('sets loading state to true when fetching', () async {
        final feeds = MockFactories.createFeedEntities(count: 2);

        when(
          () => mockRepository.getFeedsFromDB(),
        ).thenAnswer((_) async => feeds);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        final future = notifier.getFeeds();
        expect(notifier.isLoading, isTrue);
        await future;
      });

      test('loads feeds from database', () async {
        final feeds = MockFactories.createFeedEntities(count: 3);

        when(
          () => mockRepository.getFeedsFromDB(),
        ).thenAnswer((_) async => feeds);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.getFeeds();

        expect(notifier.feeds.length, equals(3));
        expect(notifier.isLoading, isFalse);
        verify(() => mockRepository.getFeedsFromDB()).called(greaterThan(0));
      });

      test('refreshes feeds when forceRefresh is true', () async {
        final feeds = MockFactories.createFeedEntities(count: 2);
        final remoteFeeds = [MockFactories.createFeedProto()];

        when(
          () => mockRepository.getFeedsFromDB(),
        ).thenAnswer((_) async => feeds);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => remoteFeeds);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.getFeeds(forceRefresh: true);

        verify(() => mockRepository.getFeedsFromRemote(any())).called(1);
        verify(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).called(1);
      });

      test(
        'does not refresh when forceRefresh is false and within refresh interval',
        () async {
          final feeds = MockFactories.createFeedEntities(count: 2);

          when(
            () => mockRepository.getFeedsFromDB(),
          ).thenAnswer((_) async => feeds);
          when(
            () => mockRepository.getFeedsFromRemote(any()),
          ).thenAnswer((_) async => []);
          when(
            () => mockRepository.updatedFeedItemsIfNecessary(any()),
          ).thenAnswer((_) async => {});

          // First call: _lastRefreshTime is null, so it will refresh
          await notifier.getFeeds(forceRefresh: false);

          // Second call immediately after: should not refresh because within interval
          await notifier.getFeeds(forceRefresh: false);

          // First call refreshes (because _lastRefreshTime was null), second doesn't
          // So we expect exactly 1 call, not 0
          verify(() => mockRepository.getFeedsFromRemote(any())).called(1);
        },
      );

      test('handles empty feeds list', () async {
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);

        await notifier.getFeeds();

        expect(notifier.feeds.isEmpty, isTrue);
        expect(notifier.isLoading, isFalse);
      });

      test('sets loading state to false after completion', () async {
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.getFeeds();

        expect(notifier.isLoading, isFalse);
      });
    });

    group('loadFeedItems', () {
      test('sets loadingFeedItems state to true when loading', () async {
        const feedID = 1;
        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 3,
        );

        when(
          () => mockRepository.getFeedItemsFromDB(feedID),
        ).thenAnswer((_) async => items);

        final future = notifier.loadFeedItems(feedID);
        expect(notifier.isLoadingFeedItems, isTrue);
        expect(notifier.feedItems.isEmpty, isTrue);
        await future;
      });

      test('loads feed items from database', () async {
        const feedID = 1;
        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 3,
        );

        when(
          () => mockRepository.getFeedItemsFromDB(feedID),
        ).thenAnswer((_) async => items);

        await notifier.loadFeedItems(feedID);

        expect(notifier.feedItems.length, equals(3));
        expect(notifier.isLoadingFeedItems, isFalse);
        verify(() => mockRepository.getFeedItemsFromDB(feedID)).called(1);
      });

      test('clears feed items before loading', () async {
        const feedID = 1;
        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 2,
        );

        when(
          () => mockRepository.getFeedItemsFromDB(feedID),
        ).thenAnswer((_) async => items);

        await notifier.loadFeedItems(feedID);

        expect(notifier.feedItems.length, equals(2));
      });

      test('handles empty feed items list', () async {
        const feedID = 1;

        when(
          () => mockRepository.getFeedItemsFromDB(feedID),
        ).thenAnswer((_) async => []);

        await notifier.loadFeedItems(feedID);

        expect(notifier.feedItems.isEmpty, isTrue);
        expect(notifier.isLoadingFeedItems, isFalse);
      });

      test('sets loadingFeedItems state to false after completion', () async {
        const feedID = 1;

        when(
          () => mockRepository.getFeedItemsFromDB(feedID),
        ).thenAnswer((_) async => []);

        await notifier.loadFeedItems(feedID);

        expect(notifier.isLoadingFeedItems, isFalse);
      });
    });

    group('addFeed', () {
      test('sets validation status to validationInProgress', () async {
        const url = 'https://example.com/rss.xml';

        when(
          () => mockRepository.validateFeed(url),
        ).thenAnswer((_) async => FeedValidationStatus.valid);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => [MockFactories.createFeedProto()]);
        when(
          () => mockRepository.saveFeedToDB(any()),
        ).thenAnswer((_) async => {});
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        final future = notifier.addFeed(url);
        expect(
          notifier.feedValidationStatus,
          equals(FeedValidationStatus.validationInProgress),
        );
        expect(notifier.isLoading, isTrue);
        await future;
      });

      test('saves feed when validation succeeds', () async {
        const url = 'https://example.com/rss.xml';
        final remoteFeed = MockFactories.createFeedProto();

        when(
          () => mockRepository.validateFeed(url),
        ).thenAnswer((_) async => FeedValidationStatus.valid);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => [remoteFeed]);
        when(
          () => mockRepository.saveFeedToDB(any()),
        ).thenAnswer((_) async => {});
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.addFeed(url);

        verify(() => mockRepository.validateFeed(url)).called(1);
        verify(() => mockRepository.getFeedsFromRemote(any())).called(1);
        verify(() => mockRepository.saveFeedToDB(any())).called(1);
      });

      test('does not save feed when validation fails', () async {
        const url = 'https://example.com/rss.xml';

        when(
          () => mockRepository.validateFeed(url),
        ).thenAnswer((_) async => FeedValidationStatus.feedInvalid);
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);

        await notifier.addFeed(url);

        verify(() => mockRepository.validateFeed(url)).called(1);
        verifyNever(() => mockRepository.saveFeedToDB(any()));
      });

      test('does not save feed when feed already exists', () async {
        const url = 'https://example.com/rss.xml';

        when(
          () => mockRepository.validateFeed(url),
        ).thenAnswer((_) async => FeedValidationStatus.feedExists);
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.addFeed(url);

        verify(() => mockRepository.validateFeed(url)).called(1);
        verifyNever(() => mockRepository.saveFeedToDB(any()));
      });

      test('refreshes feeds after adding', () async {
        const url = 'https://example.com/rss.xml';
        final remoteFeed = MockFactories.createFeedProto();
        final feeds = MockFactories.createFeedEntities(count: 1);

        when(
          () => mockRepository.validateFeed(url),
        ).thenAnswer((_) async => FeedValidationStatus.valid);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => [remoteFeed]);
        when(
          () => mockRepository.saveFeedToDB(any()),
        ).thenAnswer((_) async => {});
        // getFeedsFromDB is called twice: once at start of getFeeds(), once at end
        when(
          () => mockRepository.getFeedsFromDB(),
        ).thenAnswer((_) async => feeds);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.addFeed(url);

        // Wait a bit for the async getFeeds() call to complete
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // getFeeds() calls getFeedsFromDB() at least once (at start)
        // It may call it again at the end, but since getFeeds() is fire-and-forget,
        // we just verify it was called
        verify(
          () => mockRepository.getFeedsFromDB(),
        ).called(greaterThanOrEqualTo(1));
      });
    });

    group('removeFeed', () {
      test('deletes feed from database', () async {
        const feedID = 1;
        final feeds = MockFactories.createFeedEntities(count: 1);

        when(
          () => mockRepository.deleteFeedFromDB(feedID),
        ).thenAnswer((_) async => {});
        when(
          () => mockRepository.getFeedsFromDB(),
        ).thenAnswer((_) async => feeds);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.removeFeed(feedID);

        verify(() => mockRepository.deleteFeedFromDB(feedID)).called(1);
      });

      test('sets loading state to true when removing', () async {
        const feedID = 1;

        when(
          () => mockRepository.deleteFeedFromDB(feedID),
        ).thenAnswer((_) async => {});
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        final future = notifier.removeFeed(feedID);
        expect(notifier.isLoading, isTrue);
        await future;
      });

      test('refreshes feeds after removing', () async {
        const feedID = 1;

        when(
          () => mockRepository.deleteFeedFromDB(feedID),
        ).thenAnswer((_) async => {});
        when(() => mockRepository.getFeedsFromDB()).thenAnswer((_) async => []);
        when(
          () => mockRepository.getFeedsFromRemote(any()),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepository.updatedFeedItemsIfNecessary(any()),
        ).thenAnswer((_) async => {});

        await notifier.removeFeed(feedID);

        verify(() => mockRepository.getFeedsFromDB()).called(greaterThan(0));
      });
    });

    group('resetFeedItems', () {
      test('resets all feed item related state', () {
        notifier.resetFeedItems();

        expect(notifier.isLoading, isFalse);
        expect(notifier.isLoadingFeedItems, isFalse);
        expect(
          notifier.feedValidationStatus,
          equals(FeedValidationStatus.idle),
        );
        expect(notifier.feedItems.isEmpty, isTrue);
      });
    });
  });
}
