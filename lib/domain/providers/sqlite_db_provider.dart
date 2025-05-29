import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:sqflite/sqflite.dart';

final class SQLiteDBProvider implements DBProvider {
  final Database _database;

  SQLiteDBProvider({required Database databaseInstance})
    : _database = databaseInstance;

  @override
  Future<bool> feedExistsByURL({required String url}) async {
    const query = 'select count(*) from feeds where url = ?';
    final result = await _database.rawQuery(query, [url]);
    final count = (result.first['count'] as int?) ?? 0;
    return count > 0;
  }

  @override
  Future<int> createFeedAndReturnID({required FeedEntity feed}) async {
    final result = await _database.insert('feeds', feed.toJson());
    return result;
  }

  @override
  Future<void> createFeedItems({
    required Iterable<FeedItemEntity> feedItems,
  }) async {
    await _database.transaction((txn) async {
      await Future.wait(
        feedItems.map((item) => txn.insert('feed_items', item.toJson())),
      );
    });
  }

  @override
  Future<void> updateFeedItems({
    required int feedID,
    required Iterable<FeedItemEntity> incomingFeedItems,
  }) async {
    final existingFeedItems = await getFeedItems(feedID: feedID);
    final newFeedItems = incomingFeedItems.where(
      (item) => !existingFeedItems.any(
        (existingItem) => existingItem.link == item.link,
      ),
    );

    await _database.transaction((txn) async {
      for (final item in newFeedItems) {
        await txn.insert('feed_items', item.toJson());
      }
    });
  }

  @override
  Future<Iterable<FeedEntity>> getFeeds({
    GetFeedsOrderBy orderBy = GetFeedsOrderBy.title,
    OrderByDirection orderByDirection = OrderByDirection.ascending,
  }) async {
    final orderByColumn = switch (orderBy) {
      GetFeedsOrderBy.title => 'title',
      GetFeedsOrderBy.addedAt => 'added_at',
    };

    final orderByDirectionString = switch (orderByDirection) {
      OrderByDirection.ascending => 'asc',
      OrderByDirection.descending => 'desc',
    };

    final query =
        'select * from feeds order by $orderByColumn $orderByDirectionString';
    final result = await _database.rawQuery(query);
    return result.map((item) => FeedEntity.fromJson(item));
  }

  @override
  Future<Iterable<FeedItemEntity>> getFeedItems({required int feedID}) async {
    final query =
        'select * from feed_items where feed_id = $feedID order by created_at desc';
    final result = await _database.rawQuery(query);
    return result.map((item) => FeedItemEntity.fromJson(item));
  }

  @override
  Future<void> deleteFeed({required int feedID}) async {
    await _database.transaction((txn) async {
      await txn.delete('feed_items', where: 'feed_id = $feedID');
      await txn.delete('feeds', where: 'id = $feedID');
    });
  }
}
