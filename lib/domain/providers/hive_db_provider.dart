import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_cache.entity.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:simplest_logger/simplest_logger.dart';

final class HiveDBProvider with SimplestLoggerMixin implements DBProvider {
  final Box<FeedURLEntity> _feedURLsBox;
  final Box<FeedCacheEntity> _feedCacheBox;

  HiveDBProvider({
    required Box<FeedURLEntity> feedURLsBox,
    required Box<FeedCacheEntity> feedCacheBox,
  }) : _feedURLsBox = feedURLsBox,
       _feedCacheBox = feedCacheBox;

  @override
  Future<void> addFeedURL(String url) async {
    // Check if URL already exists
    final existingURL = _feedURLsBox.values.firstWhereOrNull(
      (feedURL) => feedURL.url.toLowerCase() == url.toLowerCase(),
    );

    if (existingURL != null) {
      logger.warning('URL already exists: $url');
      throw Exception('Feed URL already exists: $url');
    }

    // Calculate next order
    final feedURLs = _feedURLsBox.values.toList();
    final order = feedURLs.isEmpty
        ? 0
        : feedURLs.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;

    logger.info('Adding new feed URL: $url with order: $order');

    // Add new feed URL
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

    logger.info('Removing feed URL: $url');
    await _feedURLsBox.delete(feedURL.key);
  }

  @override
  List<FeedURLEntity> getFeedURLs() {
    final urls = _feedURLsBox.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    logger.info('Retrieved ${urls.length} feed URLs');
    return urls;
  }

  @override
  Future<void> cacheFeed(FeedCacheEntity feed) async {
    final existingKey = _feedCacheBox.values
        .firstWhereOrNull((cached) => cached.url == feed.url)
        ?.key;

    if (existingKey != null) {
      logger.info('Updating cache for feed: ${feed.url}');
      await _feedCacheBox.put(existingKey, feed);
    } else {
      logger.info('Creating new cache for feed: ${feed.url}');
      await _feedCacheBox.add(feed);
    }
  }

  @override
  Future<void> removeFeedCache(String url) async {
    final cachedFeed = _feedCacheBox.values.firstWhereOrNull(
      (cached) => cached.url == url,
    );

    if (cachedFeed != null) {
      logger.info('Removing cache for feed: $url');
      await _feedCacheBox.delete(cachedFeed.key);
    } else {
      logger.warning('Cache not found for feed: $url');
    }
  }

  @override
  Future<FeedCacheEntity?> getFeedCache(String url) async {
    final cache = _feedCacheBox.values.firstWhereOrNull(
      (cached) => cached.url == url,
    );
    logger.info('Retrieved cache for feed: $url - exists: ${cache != null}');
    return cache;
  }
}
