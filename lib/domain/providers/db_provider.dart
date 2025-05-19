import 'package:rss_it/domain/data/feed_cache.entity.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';

abstract interface class DBProvider {
  Future<void> addFeedURL(String url);
  Future<void> removeFeedURL(String url);
  List<FeedURLEntity> getFeedURLs();

  // Cache operations
  Future<void> cacheFeed(FeedCacheEntity feed);
  Future<void> removeFeedCache(String url);
  Future<FeedCacheEntity?> getFeedCache(String url);
}
