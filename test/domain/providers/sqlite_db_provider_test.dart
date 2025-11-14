import 'package:flutter_test/flutter_test.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:rss_it/domain/providers/sqlite_db_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/mock_factories.dart';
import '../../helpers/test_database.dart';

void main() {
  setUpAll(() {
    TestDatabase.initialize();
  });

  group('SQLiteDBProvider', () {
    late Database database;
    late SQLiteDBProvider provider;

    setUp(() async {
      database = await TestDatabase.createInMemoryDatabase();
      provider = SQLiteDBProvider(databaseInstance: database);
    });

    tearDown(() async {
      // Clear all data between tests to avoid ID conflicts
      await database.delete('feed_items');
      await database.delete('feeds');
      // Don't close database here - it will be closed in tearDownAll
    });

    group('feedExistsByURL', () {
      test('returns false when feed does not exist', () async {
        final exists = await provider.feedExistsByURL(
          url: 'https://example.com/rss.xml',
        );
        expect(exists, isFalse);
      });

      test('returns true when feed exists', () async {
        final feed = MockFactories.createFeedEntity();
        await provider.createFeedAndReturnID(feed: feed);

        final exists = await provider.feedExistsByURL(url: feed.url);
        expect(exists, isTrue);
      });

      test('returns false for different URL', () async {
        final feed = MockFactories.createFeedEntity(
          url: 'https://example.com/rss1.xml',
        );
        await provider.createFeedAndReturnID(feed: feed);

        final exists = await provider.feedExistsByURL(
          url: 'https://example.com/rss2.xml',
        );
        expect(exists, isFalse);
      });
    });

    group('createFeedAndReturnID', () {
      test('creates feed and returns ID', () async {
        final feed = MockFactories.createFeedEntity();

        final id = await provider.createFeedAndReturnID(feed: feed);

        expect(id, isPositive);
        expect(id, isA<int>());
      });

      test('creates feed with all fields', () async {
        final feed = MockFactories.createFeedEntity(
          url: 'https://example.com/rss.xml',
          title: 'Test Feed',
          description: 'Test Description',
          thumbnailURL: 'https://example.com/thumbnail.png',
        );

        final id = await provider.createFeedAndReturnID(feed: feed);

        final feeds = await provider.getFeeds();
        final createdFeed = feeds.firstWhere((f) => f.id == id);

        expect(createdFeed.url, equals(feed.url));
        expect(createdFeed.title, equals(feed.title));
        expect(createdFeed.description, equals(feed.description));
        expect(createdFeed.thumbnailURL, equals(feed.thumbnailURL));
      });

      test('creates feed with nullable fields as null', () async {
        // Create feed with explicit null values (not using MockFactories defaults)
        final feed = FeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
          title: 'Test Feed',
          description: null, // Explicitly null
          thumbnailURL: null, // Explicitly null
          addedAt: DateTime(2024, 1, 1),
        );

        final id = await provider.createFeedAndReturnID(feed: feed);

        final feeds = await provider.getFeeds();
        final createdFeed = feeds.firstWhere((f) => f.id == id);

        expect(createdFeed.description, isNull);
        expect(createdFeed.thumbnailURL, isNull);
      });
    });

    group('createFeedItems', () {
      test('creates feed items', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 3,
        );

        await provider.createFeedItems(feedItems: items);

        final createdItems = await provider.getFeedItems(feedID: feedID);
        expect(createdItems.length, equals(3));
      });

      test('creates feed items with all fields', () async {
        final feed = MockFactories.createFeedEntity();
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final item = MockFactories.createFeedItemEntity(
          feedID: feedID,
          link: 'https://example.com/article/1',
          title: 'Test Article',
          description: 'Test Description',
          imageURL: 'https://example.com/image.png',
        );

        await provider.createFeedItems(feedItems: [item]);

        final createdItems = await provider.getFeedItems(feedID: feedID);
        final createdItem = createdItems.first;

        expect(createdItem.link, equals(item.link));
        expect(createdItem.title, equals(item.title));
        expect(createdItem.description, equals(item.description));
        expect(createdItem.imageURL, equals(item.imageURL));
      });

      test('creates multiple feed items in transaction', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 5,
        );

        await provider.createFeedItems(feedItems: items);

        final createdItems = await provider.getFeedItems(feedID: feedID);
        expect(createdItems.length, equals(5));
      });
    });

    group('updateFeedItems', () {
      test('adds new feed items that do not exist', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final existingItems = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 2,
        );
        await provider.createFeedItems(feedItems: existingItems);

        final newItems = [
          MockFactories.createFeedItemEntity(
            feedID: feedID,
            link: 'https://example.com/article/new',
            title: 'New Article',
          ),
        ];

        await provider.updateFeedItems(
          feedID: feedID,
          incomingFeedItems: newItems,
        );

        final allItems = await provider.getFeedItems(feedID: feedID);
        expect(allItems.length, equals(3));
      });

      test('does not add duplicate feed items', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final existingItem = MockFactories.createFeedItemEntity(
          feedID: feedID,
          link: 'https://example.com/article/1',
          title: 'Existing Article',
        );
        await provider.createFeedItems(feedItems: [existingItem]);

        final duplicateItem = MockFactories.createFeedItemEntity(
          feedID: feedID,
          link: 'https://example.com/article/1',
          title: 'Duplicate Article',
        );

        await provider.updateFeedItems(
          feedID: feedID,
          incomingFeedItems: [duplicateItem],
        );

        final allItems = await provider.getFeedItems(feedID: feedID);
        expect(allItems.length, equals(1));
        expect(allItems.first.title, equals('Existing Article'));
      });

      test('handles empty incoming feed items', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final existingItems = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 2,
        );
        await provider.createFeedItems(feedItems: existingItems);

        await provider.updateFeedItems(feedID: feedID, incomingFeedItems: []);

        final allItems = await provider.getFeedItems(feedID: feedID);
        expect(allItems.length, equals(2));
      });
    });

    group('getFeeds', () {
      test('returns empty list when no feeds exist', () async {
        final feeds = await provider.getFeeds();
        expect(feeds.isEmpty, isTrue);
      });

      test('returns all feeds', () async {
        final feed1 = MockFactories.createFeedEntity(
          id: null,
          title: 'Feed 1',
          url: 'https://example.com/rss1.xml',
        );
        final feed2 = MockFactories.createFeedEntity(
          id: null,
          title: 'Feed 2',
          url: 'https://example.com/rss2.xml',
        );

        await provider.createFeedAndReturnID(feed: feed1);
        await provider.createFeedAndReturnID(feed: feed2);

        final feeds = await provider.getFeeds();
        expect(feeds.length, equals(2));
      });

      test('orders feeds by title ascending', () async {
        final feed1 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss1.xml',
          title: 'Z Feed',
        );
        final feed2 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss2.xml',
          title: 'A Feed',
        );
        final feed3 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss3.xml',
          title: 'M Feed',
        );

        await provider.createFeedAndReturnID(feed: feed1);
        await provider.createFeedAndReturnID(feed: feed2);
        await provider.createFeedAndReturnID(feed: feed3);

        final feeds = await provider.getFeeds(
          orderBy: GetFeedsOrderBy.title,
          orderByDirection: OrderByDirection.ascending,
        );

        expect(feeds.length, equals(3));
        expect(feeds.elementAt(0).title, equals('A Feed'));
        expect(feeds.elementAt(1).title, equals('M Feed'));
        expect(feeds.elementAt(2).title, equals('Z Feed'));
      });

      test('orders feeds by title descending', () async {
        final feed1 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss1.xml',
          title: 'A Feed',
        );
        final feed2 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss2.xml',
          title: 'Z Feed',
        );

        await provider.createFeedAndReturnID(feed: feed1);
        await provider.createFeedAndReturnID(feed: feed2);

        final feeds = await provider.getFeeds(
          orderBy: GetFeedsOrderBy.title,
          orderByDirection: OrderByDirection.descending,
        );

        expect(feeds.length, equals(2));
        expect(feeds.elementAt(0).title, equals('Z Feed'));
        expect(feeds.elementAt(1).title, equals('A Feed'));
      });

      test('orders feeds by addedAt ascending', () async {
        final feed1 = MockFactories.createFeedEntity(
          addedAt: DateTime(2024, 1, 3),
        );
        final feed2 = MockFactories.createFeedEntity(
          addedAt: DateTime(2024, 1, 1),
        );
        final feed3 = MockFactories.createFeedEntity(
          addedAt: DateTime(2024, 1, 2),
        );

        await provider.createFeedAndReturnID(feed: feed1);
        await provider.createFeedAndReturnID(feed: feed2);
        await provider.createFeedAndReturnID(feed: feed3);

        final feeds = await provider.getFeeds(
          orderBy: GetFeedsOrderBy.addedAt,
          orderByDirection: OrderByDirection.ascending,
        );

        expect(feeds.length, equals(3));
        expect(feeds.elementAt(0).addedAt, equals(DateTime(2024, 1, 1)));
        expect(feeds.elementAt(1).addedAt, equals(DateTime(2024, 1, 2)));
        expect(feeds.elementAt(2).addedAt, equals(DateTime(2024, 1, 3)));
      });

      test('orders feeds by addedAt descending', () async {
        final feed1 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss1.xml',
          addedAt: DateTime(2024, 1, 1),
        );
        final feed2 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss2.xml',
          addedAt: DateTime(2024, 1, 2),
        );

        await provider.createFeedAndReturnID(feed: feed1);
        await provider.createFeedAndReturnID(feed: feed2);

        final feeds = await provider.getFeeds(
          orderBy: GetFeedsOrderBy.addedAt,
          orderByDirection: OrderByDirection.descending,
        );

        expect(feeds.length, equals(2));
        expect(feeds.elementAt(0).addedAt, equals(DateTime(2024, 1, 2)));
        expect(feeds.elementAt(1).addedAt, equals(DateTime(2024, 1, 1)));
      });
    });

    group('getFeedItems', () {
      test('returns empty list when no feed items exist', () async {
        final feed = MockFactories.createFeedEntity();
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final items = await provider.getFeedItems(feedID: feedID);
        expect(items.isEmpty, isTrue);
      });

      test('returns feed items for specific feed', () async {
        final feed1 = MockFactories.createFeedEntity();
        final feed2 = MockFactories.createFeedEntity();
        final feedID1 = await provider.createFeedAndReturnID(feed: feed1);
        final feedID2 = await provider.createFeedAndReturnID(feed: feed2);

        final items1 = MockFactories.createFeedItemEntities(
          feedID: feedID1,
          count: 2,
        );
        final items2 = MockFactories.createFeedItemEntities(
          feedID: feedID2,
          count: 3,
        );

        await provider.createFeedItems(feedItems: items1);
        await provider.createFeedItems(feedItems: items2);

        final feed1Items = await provider.getFeedItems(feedID: feedID1);
        final feed2Items = await provider.getFeedItems(feedID: feedID2);

        expect(feed1Items.length, equals(2));
        expect(feed2Items.length, equals(3));
      });

      test('orders feed items by created_at descending', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final item1 = MockFactories.createFeedItemEntity(
          id: null,
          feedID: feedID,
          link: 'https://example.com/article/1',
          createdAt: DateTime(2024, 1, 1, 10, 0),
        );
        final item2 = MockFactories.createFeedItemEntity(
          id: null,
          feedID: feedID,
          link: 'https://example.com/article/2',
          createdAt: DateTime(2024, 1, 1, 12, 0),
        );
        final item3 = MockFactories.createFeedItemEntity(
          id: null,
          feedID: feedID,
          link: 'https://example.com/article/3',
          createdAt: DateTime(2024, 1, 1, 11, 0),
        );

        await provider.createFeedItems(feedItems: [item1, item2, item3]);

        final items = await provider.getFeedItems(feedID: feedID);

        expect(items.length, equals(3));
        expect(
          items.elementAt(0).createdAt,
          equals(DateTime(2024, 1, 1, 12, 0)),
        );
        expect(
          items.elementAt(1).createdAt,
          equals(DateTime(2024, 1, 1, 11, 0)),
        );
        expect(
          items.elementAt(2).createdAt,
          equals(DateTime(2024, 1, 1, 10, 0)),
        );
      });
    });

    group('deleteFeed', () {
      test('deletes feed and its feed items', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 3,
        );
        await provider.createFeedItems(feedItems: items);

        await provider.deleteFeed(feedID: feedID);

        final feeds = await provider.getFeeds();
        final feedItems = await provider.getFeedItems(feedID: feedID);

        expect(feeds.isEmpty, isTrue);
        expect(feedItems.isEmpty, isTrue);
      });

      test('does not delete other feeds', () async {
        final feed1 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss1.xml',
        );
        final feed2 = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss2.xml',
        );
        final feedID1 = await provider.createFeedAndReturnID(feed: feed1);
        final feedID2 = await provider.createFeedAndReturnID(feed: feed2);

        final items1 = MockFactories.createFeedItemEntities(
          feedID: feedID1,
          count: 2,
        );
        final items2 = MockFactories.createFeedItemEntities(
          feedID: feedID2,
          count: 2,
        );

        await provider.createFeedItems(feedItems: items1);
        await provider.createFeedItems(feedItems: items2);

        await provider.deleteFeed(feedID: feedID1);

        final feeds = await provider.getFeeds();
        final feed1Items = await provider.getFeedItems(feedID: feedID1);
        final feed2Items = await provider.getFeedItems(feedID: feedID2);

        expect(feeds.length, equals(1));
        expect(feeds.first.id, equals(feedID2));
        expect(feed1Items.isEmpty, isTrue);
        expect(feed2Items.length, equals(2));
      });

      test('handles deleting non-existent feed', () async {
        await expectLater(provider.deleteFeed(feedID: 999), completes);
      });
    });

    group('Foreign Key Constraints', () {
      test('cascade delete removes feed items when feed is deleted', () async {
        final feed = MockFactories.createFeedEntity(
          id: null,
          url: 'https://example.com/rss.xml',
        );
        final feedID = await provider.createFeedAndReturnID(feed: feed);

        final items = MockFactories.createFeedItemEntities(
          feedID: feedID,
          count: 3,
        );
        await provider.createFeedItems(feedItems: items);

        await provider.deleteFeed(feedID: feedID);

        // Verify feed items are deleted via foreign key cascade
        final allItems = await database.rawQuery(
          'SELECT COUNT(*) as count FROM feed_items WHERE feed_id = ?',
          [feedID],
        );
        expect(allItems.first['count'], equals(0));
      });
    });
  });
}
