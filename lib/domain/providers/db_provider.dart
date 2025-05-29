import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';

enum GetFeedsOrderBy { title, addedAt }

enum OrderByDirection { ascending, descending }

abstract interface class DBProvider {
  Future<bool> feedExistsByURL({required String url});

  Future<int> createFeedAndReturnID({required FeedEntity feed});
  Future<void> createFeedItems({required Iterable<FeedItemEntity> feedItems});

  Future<void> updateFeedItems({
    required int feedID,
    required Iterable<FeedItemEntity> incomingFeedItems,
  });

  Future<Iterable<FeedEntity>> getFeeds({
    GetFeedsOrderBy orderBy = GetFeedsOrderBy.title,
    OrderByDirection orderByDirection = OrderByDirection.ascending,
  });
  Future<Iterable<FeedItemEntity>> getFeedItems({required int feedID});

  Future<void> deleteFeed({required int feedID});
}
