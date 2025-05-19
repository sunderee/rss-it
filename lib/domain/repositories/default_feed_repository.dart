import 'dart:async';

import 'package:collection/collection.dart';
import 'package:rss_it/domain/data/feed_cache.entity.dart';
import 'package:rss_it/domain/data/feed_model.entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:rss_it/domain/providers/rss_library_provider.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';

final class DefaultFeedRepository implements FeedRepository {
  final DBProvider _dbProvider;
  final RssLibraryProvider _rssLibraryProvider;
  final _feedsController =
      StreamController<List<ParseFeedResponseFeedModel>>.broadcast();

  Timer? _refreshTimer;

  DefaultFeedRepository({
    required DBProvider dbProviderInstance,
    required RssLibraryProvider rssLibraryProviderInstance,
  }) : _dbProvider = dbProviderInstance,
       _rssLibraryProvider = rssLibraryProviderInstance {
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => refreshFeeds(),
    );
  }

  @override
  Future<void> addFeedURL(String url) async {
    // Validate feed URL
    final isFeedURLValid = await _rssLibraryProvider.validateFeedURL(url);
    if (!isFeedURLValid) {
      throw Exception('Invalid feed URL: $url');
    }

    // Add feed URL to DB
    await _dbProvider.addFeedURL(url);

    // Trigger a refresh to include the new feed
    await refreshFeeds();
  }

  @override
  Future<void> removeFeedURL(String url) async {
    await _dbProvider.removeFeedURL(url);
    await _dbProvider.removeFeedCache(url);

    // Update the stream with remaining feeds
    final remainingFeeds = await _getCachedFeeds();
    _feedsController.add(remainingFeeds);
  }

  @override
  Stream<List<ParseFeedResponseFeedModel>> getFeedsStream() async* {
    // First emit cached data
    final cachedFeeds = await _getCachedFeeds();
    yield cachedFeeds;

    // Then try to fetch fresh data
    try {
      final freshFeeds = await _fetchFeedsFromNetwork();
      yield freshFeeds;
    } catch (e) {
      // If network fetch fails, we keep using cached data
      // TODO: Replace with logger if available
    }
  }

  @override
  Future<void> refreshFeeds() async {
    try {
      final freshFeeds = await _fetchFeedsFromNetwork();
      _feedsController.add(freshFeeds);
    } catch (e) {
      // TODO: Replace with logger if available
      rethrow;
    }
  }

  Future<List<ParseFeedResponseFeedModel>> _getCachedFeeds() async {
    final feedURLs = _dbProvider.getFeedURLs();
    final cachedFeeds = <ParseFeedResponseFeedModel>[];

    for (final feedURL in feedURLs) {
      final cachedFeed = await _dbProvider.getFeedCache(feedURL.url);
      if (cachedFeed != null && !cachedFeed.isError) {
        cachedFeeds.add(cachedFeed.feed.toModel());
      }
    }

    return _orderFeeds(cachedFeeds, feedURLs);
  }

  Future<List<ParseFeedResponseFeedModel>> _fetchFeedsFromNetwork() async {
    final feedURLs = _dbProvider.getFeedURLs();
    if (feedURLs.isEmpty) return [];

    try {
      final parsedFeeds = await _rssLibraryProvider.parseFeedURLs(
        feedURLs.map((item) => item.url).toList(),
      );

      // Cache the successful results
      for (final feed in parsedFeeds.feeds) {
        await _dbProvider.cacheFeed(
          FeedCacheEntity(
            url: feed.url,
            feed: FeedModelEntity.fromModel(feed),
            lastUpdated: DateTime.now(),
          ),
        );
      }

      return _orderFeeds(parsedFeeds.feeds, feedURLs);
    } catch (e) {
      // Cache the error
      for (final feedURL in feedURLs) {
        await _dbProvider.cacheFeed(
          FeedCacheEntity(
            url: feedURL.url,
            feed: FeedModelEntity(
              url: feedURL.url,
              title: '',
              description: '',
              imageUrl: null,
              imageTitle: null,
              items: const [],
            ),
            lastUpdated: DateTime.now(),
            isError: true,
            errorMessage: e.toString(),
          ),
        );
      }
      rethrow;
    }
  }

  List<ParseFeedResponseFeedModel> _orderFeeds(
    List<ParseFeedResponseFeedModel> feeds,
    List<dynamic> feedURLs,
  ) {
    final orderedFeeds = <ParseFeedResponseFeedModel>[];
    for (final feedURL in feedURLs) {
      final feed = feeds.firstWhereOrNull((feed) => feed.url == feedURL.url);
      if (feed != null) {
        orderedFeeds.add(feed);
      }
    }
    return orderedFeeds;
  }

  void dispose() {
    _refreshTimer?.cancel();
    _feedsController.close();
  }
}
