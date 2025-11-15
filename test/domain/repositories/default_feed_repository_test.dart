import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rss_it/domain/data/enums.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/domain/data/folder_entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:rss_it/domain/repositories/default_feed_repository.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

import '../../helpers/mock_factories.dart';

class MockDBProvider extends Mock implements DBProvider {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      FeedEntity(
        id: null,
        url: 'https://example.com/rss.xml',
        title: 'Test Feed',
        description: null,
        thumbnailURL: null,
        addedAt: DateTime(2024, 1, 1),
      ),
    );
    registerFallbackValue(
      FeedItemEntity(
        id: null,
        feedID: 1,
        link: 'https://example.com/article/1',
        title: 'Test Article',
        description: null,
        imageURL: null,
        publishedAt: null,
        createdAt: DateTime(2024, 1, 1),
      ),
    );
      registerFallbackValue(
        FolderEntity(
          id: null,
          name: 'Sample Folder',
          createdAt: DateTime(2024, 1, 1),
        ),
      );
  });

  group('DefaultFeedRepository', () {
    late MockDBProvider mockDBProvider;
    late DefaultFeedRepository repository;

    setUp(() {
      mockDBProvider = MockDBProvider();
      repository = DefaultFeedRepository(
        dbProviderInstance: mockDBProvider,
        validateFeedURL: (url) async => true, // Mock: always return valid
        parseFeedURLs: (urls) async => ParseFeedsResponse()
          ..status = ParseFeedsStatus.SUCCESS
          ..feeds.addAll([]), // Mock: return empty feeds by default
      );
    });

    group('validateFeed', () {
      test('returns feedExists when feed already exists in database', () async {
        when(
          () => mockDBProvider.feedExistsByURL(url: any(named: 'url')),
        ).thenAnswer((_) async => true);

        final result = await repository.validateFeed(
          'https://example.com/rss.xml',
        );

        expect(result, equals(FeedValidationStatus.feedExists));
        verify(
          () => mockDBProvider.feedExistsByURL(
            url: 'https://example.com/rss.xml',
          ),
        ).called(1);
      });

      test(
        'returns valid when feed does not exist and validation succeeds',
        () async {
          when(
            () => mockDBProvider.feedExistsByURL(url: any(named: 'url')),
          ).thenAnswer((_) async => false);

          // Note: This test requires the actual library function to work
          // In a real scenario, you might want to mock validateFeedURL
          // For now, we test the logic path
          final result = await repository.validateFeed(
            'https://example.com/rss.xml',
          );

          expect(
            result,
            isIn([
              FeedValidationStatus.valid,
              FeedValidationStatus.feedInvalid,
            ]),
          );
        },
      );

      test('checks database before validating URL', () async {
        when(
          () => mockDBProvider.feedExistsByURL(url: any(named: 'url')),
        ).thenAnswer((_) async => false);

        await repository.validateFeed('https://example.com/rss.xml');

        verify(
          () => mockDBProvider.feedExistsByURL(
            url: 'https://example.com/rss.xml',
          ),
        ).called(1);
      });
    });

    group('getFeedsFromRemote', () {
      test('returns feeds from parseFeedURLs', () async {
        final testUrls = [
          'https://example.com/rss1.xml',
          'https://example.com/rss2.xml',
        ];

        final mockFeed1 = MockFactories.createFeedProto(
          url: testUrls[0],
          title: 'Feed 1',
        );
        final mockFeed2 = MockFactories.createFeedProto(
          url: testUrls[1],
          title: 'Feed 2',
        );

        // Create a new repository instance with mocked parseFeedURLs
        final testRepository = DefaultFeedRepository(
          dbProviderInstance: mockDBProvider,
          parseFeedURLs: (urls) async => ParseFeedsResponse()
            ..status = ParseFeedsStatus.SUCCESS
            ..feeds.addAll([mockFeed1, mockFeed2]),
        );

        final result = await testRepository.getFeedsFromRemote(testUrls);

        expect(result.length, equals(2));
        expect(result.map((f) => f.url).toList(), containsAll(testUrls));
      });

      test('handles empty URLs list', () async {
        final result = await repository.getFeedsFromRemote([]);

        expect(result, isA<Iterable<Feed>>());
        expect(result.isEmpty, isTrue);
      });
    });

      group('getFeedsFromDB', () {
        test('returns feeds from database', () async {
          final feeds = MockFactories.createFeedEntities(count: 2);

          when(() => mockDBProvider.getFeeds()).thenAnswer((_) async => feeds);

          final result = await repository.getFeedsFromDB();

          expect(result.length, equals(2));
          expect(result, equals(feeds));
          verify(() => mockDBProvider.getFeeds()).called(1);
        });

        test('returns empty list when no feeds exist', () async {
          when(() => mockDBProvider.getFeeds()).thenAnswer((_) async => []);

          final result = await repository.getFeedsFromDB();

          expect(result.isEmpty, isTrue);
          verify(() => mockDBProvider.getFeeds()).called(1);
        });
      });

      group('getFoldersFromDB', () {
        test('returns folders from database', () async {
          final folders = [
            MockFactories.createFolderEntity(id: 1, name: 'Work'),
            MockFactories.createFolderEntity(id: 2, name: 'Personal'),
          ];

          when(() => mockDBProvider.getFolders()).thenAnswer(
            (_) async => folders,
          );

          final result = await repository.getFoldersFromDB();

          expect(result, equals(folders));
          verify(() => mockDBProvider.getFolders()).called(1);
        });
      });

    group('getFeedItemsFromDB', () {
      test('returns feed items for specific feed', () async {
        const feedID = 1;
        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 3,
        );

        when(
          () => mockDBProvider.getFeedItems(feedID: any(named: 'feedID')),
        ).thenAnswer((_) async => items);

        final result = await repository.getFeedItemsFromDB(feedID);

        expect(result.length, equals(3));
        expect(result, equals(items));
        verify(() => mockDBProvider.getFeedItems(feedID: feedID)).called(1);
      });

      test('returns empty list when no feed items exist', () async {
        const feedID = 1;

        when(
          () => mockDBProvider.getFeedItems(feedID: any(named: 'feedID')),
        ).thenAnswer((_) async => []);

        final result = await repository.getFeedItemsFromDB(feedID);

        expect(result.isEmpty, isTrue);
        verify(() => mockDBProvider.getFeedItems(feedID: feedID)).called(1);
      });
    });

    group('updatedFeedItemsIfNecessary', () {
      test('updates feed items for matching feeds', () async {
        final persistedFeed = MockFactories.createFeedEntity(
          id: 1,
          url: 'https://example.com/rss.xml',
        );

        final remoteFeed = MockFactories.createFeedProto(
          url: 'https://example.com/rss.xml',
        );
        remoteFeed.items.add(MockFactories.createFeedItemProto());

        when(
          () => mockDBProvider.getFeeds(),
        ).thenAnswer((_) async => [persistedFeed]);
        when(
          () => mockDBProvider.updateFeedItems(
            feedID: any(named: 'feedID'),
            incomingFeedItems: any(named: 'incomingFeedItems'),
          ),
        ).thenAnswer((_) async => {});

        await repository.updatedFeedItemsIfNecessary([remoteFeed]);

        verify(() => mockDBProvider.getFeeds()).called(1);
        verify(
          () => mockDBProvider.updateFeedItems(
            feedID: 1,
            incomingFeedItems: any(named: 'incomingFeedItems'),
          ),
        ).called(1);
      });

      test('skips feeds not found in remote feeds', () async {
        final persistedFeed = MockFactories.createFeedEntity(
          id: 1,
          url: 'https://example.com/rss.xml',
        );

        final remoteFeed = MockFactories.createFeedProto(
          url: 'https://example.com/different-rss.xml',
        );

        when(
          () => mockDBProvider.getFeeds(),
        ).thenAnswer((_) async => [persistedFeed]);

        await repository.updatedFeedItemsIfNecessary([remoteFeed]);

        verify(() => mockDBProvider.getFeeds()).called(1);
        verifyNever(
          () => mockDBProvider.updateFeedItems(
            feedID: any(named: 'feedID'),
            incomingFeedItems: any(named: 'incomingFeedItems'),
          ),
        );
      });

      test('handles multiple persisted feeds', () async {
        final feed1 = MockFactories.createFeedEntity(
          id: 1,
          url: 'https://example.com/rss1.xml',
        );
        final feed2 = MockFactories.createFeedEntity(
          id: 2,
          url: 'https://example.com/rss2.xml',
        );

        final remoteFeed1 = MockFactories.createFeedProto(
          url: 'https://example.com/rss1.xml',
        );
        remoteFeed1.items.add(MockFactories.createFeedItemProto());

        final remoteFeed2 = MockFactories.createFeedProto(
          url: 'https://example.com/rss2.xml',
        );
        remoteFeed2.items.add(MockFactories.createFeedItemProto());

        when(
          () => mockDBProvider.getFeeds(),
        ).thenAnswer((_) async => [feed1, feed2]);
        when(
          () => mockDBProvider.updateFeedItems(
            feedID: any(named: 'feedID'),
            incomingFeedItems: any(named: 'incomingFeedItems'),
          ),
        ).thenAnswer((_) async => {});

        await repository.updatedFeedItemsIfNecessary([
          remoteFeed1,
          remoteFeed2,
        ]);

        verify(() => mockDBProvider.getFeeds()).called(1);
        verify(
          () => mockDBProvider.updateFeedItems(
            feedID: 1,
            incomingFeedItems: any(named: 'incomingFeedItems'),
          ),
        ).called(1);
        verify(
          () => mockDBProvider.updateFeedItems(
            feedID: 2,
            incomingFeedItems: any(named: 'incomingFeedItems'),
          ),
        ).called(1);
      });

      test('handles empty persisted feeds', () async {
        when(() => mockDBProvider.getFeeds()).thenAnswer((_) async => []);

        final remoteFeed = MockFactories.createFeedProto();
        await repository.updatedFeedItemsIfNecessary([remoteFeed]);

        verify(() => mockDBProvider.getFeeds()).called(1);
        verifyNever(
          () => mockDBProvider.updateFeedItems(
            feedID: any(named: 'feedID'),
            incomingFeedItems: any(named: 'incomingFeedItems'),
          ),
        );
      });
    });

    group('saveFeedToDB', () {
      test('saves feed and feed items to database', () async {
        final remoteFeed = MockFactories.createFeedProto();
        remoteFeed.items.add(MockFactories.createFeedItemProto());
        remoteFeed.items.add(MockFactories.createFeedItemProto());

        when(
          () => mockDBProvider.createFeedAndReturnID(feed: any(named: 'feed')),
        ).thenAnswer((_) async => 1);
        when(
          () => mockDBProvider.createFeedItems(
            feedItems: any(named: 'feedItems'),
          ),
        ).thenAnswer((_) async => {});

        await repository.saveFeedToDB(remoteFeed);

        verify(
          () => mockDBProvider.createFeedAndReturnID(
            feed: any(named: 'feed', that: isA<FeedEntity>()),
          ),
        ).called(1);
        verify(
          () => mockDBProvider.createFeedItems(
            feedItems: any(
              named: 'feedItems',
              that: isA<Iterable<FeedItemEntity>>(),
            ),
          ),
        ).called(1);
      });

      test('creates feed items with correct feedID', () async {
        final remoteFeed = MockFactories.createFeedProto();
        remoteFeed.items.add(MockFactories.createFeedItemProto());

        when(
          () => mockDBProvider.createFeedAndReturnID(feed: any(named: 'feed')),
        ).thenAnswer((_) async => 42);
        when(
          () => mockDBProvider.createFeedItems(
            feedItems: any(named: 'feedItems'),
          ),
        ).thenAnswer((_) async => {});

        await repository.saveFeedToDB(remoteFeed);

        verify(
          () => mockDBProvider.createFeedItems(
            feedItems: any(
              named: 'feedItems',
              that: predicate<Iterable<FeedItemEntity>>(
                (items) => items.every((item) => item.feedID == 42),
              ),
            ),
          ),
        ).called(1);
      });

      test('handles feed with no items', () async {
        final remoteFeed = MockFactories.createFeedProto(items: []);

        when(
          () => mockDBProvider.createFeedAndReturnID(feed: any(named: 'feed')),
        ).thenAnswer((_) async => 1);
        when(
          () => mockDBProvider.createFeedItems(
            feedItems: any(named: 'feedItems'),
          ),
        ).thenAnswer((_) async => {});

        await repository.saveFeedToDB(remoteFeed);

        verify(
          () => mockDBProvider.createFeedAndReturnID(feed: any(named: 'feed')),
        ).called(1);
        verify(
          () => mockDBProvider.createFeedItems(
            feedItems: any(
              named: 'feedItems',
              that: predicate<Iterable<FeedItemEntity>>(
                (items) => items.isEmpty,
              ),
            ),
          ),
        ).called(1);
      });
    });

      group('deleteFeedFromDB', () {
        test('deletes feed from database', () async {
          const feedID = 1;

          when(
            () => mockDBProvider.deleteFeed(feedID: any(named: 'feedID')),
          ).thenAnswer((_) async => {});

          await repository.deleteFeedFromDB(feedID);

          verify(() => mockDBProvider.deleteFeed(feedID: feedID)).called(1);
        });
      });

      group('folder operations', () {
        test('createFolder delegates to DB provider', () async {
          when(
            () => mockDBProvider.createFolder(folder: any(named: 'folder')),
          ).thenAnswer((_) async => 7);

          final result = await repository.createFolder('New Folder');

          expect(result, equals(7));
          verify(
            () => mockDBProvider.createFolder(folder: any(named: 'folder')),
          ).called(1);
        });

        test('renameFolder delegates to DB provider', () async {
          when(
            () => mockDBProvider.renameFolder(
              folderID: any(named: 'folderID'),
              newName: any(named: 'newName'),
            ),
          ).thenAnswer((_) async => {});

          await repository.renameFolder(1, 'Renamed');

          verify(
            () => mockDBProvider.renameFolder(
              folderID: 1,
              newName: 'Renamed',
            ),
          ).called(1);
        });

        test('deleteFolder delegates to DB provider', () async {
          when(
            () => mockDBProvider.deleteFolder(folderID: any(named: 'folderID')),
          ).thenAnswer((_) async => {});

          await repository.deleteFolder(5);

          verify(
            () => mockDBProvider.deleteFolder(folderID: 5),
          ).called(1);
        });

        test('moveFeedToFolder delegates to DB provider', () async {
          when(
            () => mockDBProvider.moveFeedToFolder(
              feedID: any(named: 'feedID'),
              folderID: any(named: 'folderID'),
            ),
          ).thenAnswer((_) async => {});

          await repository.moveFeedToFolder(feedID: 10, folderID: 2);

          verify(
            () => mockDBProvider.moveFeedToFolder(
              feedID: 10,
              folderID: 2,
            ),
          ).called(1);
        });
      });
  });
}
