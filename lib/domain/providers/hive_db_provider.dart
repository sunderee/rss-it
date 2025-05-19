import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_cache.entity.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';

final class HiveDBProvider implements DBProvider {
  final Box<FeedURLEntity> _feedURLsBox;
  final Box<FeedCacheEntity> _feedCacheBox;

  HiveDBProvider({
    required Box<FeedURLEntity> feedURLsBox,
    required Box<FeedCacheEntity> feedCacheBox,
  }) : _feedURLsBox = feedURLsBox,
       _feedCacheBox = feedCacheBox;

  @override
  Future<void> addFeedURL(String url) async {
    final feedURLs = _feedURLsBox.values.toList();
    final order =
        feedURLs.isEmpty
            ? 0
            : feedURLs.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;

    await _feedURLsBox.add(
      FeedURLEntity(url: url, order: order, added: DateTime.now()),
    );
  }

  @override
  Future<void> removeFeedURL(String url) async {
    final feedURL = _feedURLsBox.values.firstWhere(
      (feedURL) => feedURL.url == url,
      orElse: () => throw Exception('Feed URL not found: $url'),
    );

    await _feedURLsBox.delete(feedURL.key);
  }

  @override
  List<FeedURLEntity> getFeedURLs() {
    return _feedURLsBox.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<void> cacheFeed(FeedCacheEntity feed) async {
    final existingKey =
        _feedCacheBox.values
            .firstWhereOrNull((cached) => cached.url == feed.url)
            ?.key;

    if (existingKey != null) {
      await _feedCacheBox.put(existingKey, feed);
    } else {
      await _feedCacheBox.add(feed);
    }
  }

  @override
  Future<void> removeFeedCache(String url) async {
    final cachedFeed = _feedCacheBox.values.firstWhereOrNull(
      (cached) => cached.url == url,
    );

    if (cachedFeed != null) {
      await _feedCacheBox.delete(cachedFeed.key);
    }
  }

  @override
  Future<FeedCacheEntity?> getFeedCache(String url) async {
    return _feedCacheBox.values.firstWhereOrNull((cached) => cached.url == url);
  }
}
