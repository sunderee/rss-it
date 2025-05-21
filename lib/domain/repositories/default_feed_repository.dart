import 'dart:async';

import 'package:collection/collection.dart';
import 'package:rss_it/domain/data/feed_cache.entity.dart';
import 'package:rss_it/domain/data/feed_model.entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:rss_it/domain/providers/rss_library_provider.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';
import 'package:simplest_logger/simplest_logger.dart';

final class DefaultFeedRepository
    with SimplestLoggerMixin
    implements FeedRepository {
  final DBProvider _dbProvider;
  final RssLibraryProvider _rssLibraryProvider;
  final _feedsStreamController =
      StreamController<List<ParseFeedResponseFeedModel>>.broadcast();
  Timer? _refreshTimer;

  Stream<List<ParseFeedResponseFeedModel>> get feedsStream =>
      _feedsStreamController.stream;

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

    logger.info(
      'DefaultFeedRepository initialized with periodic refresh every 15 minutes',
    );
  }

  @override
  Future<void> addFeedURL(String url) async {
    logger.info('Adding feed URL: $url');

    // Validate feed URL
    final isFeedURLValid = await _rssLibraryProvider.validateFeedURL(url);
    if (!isFeedURLValid) {
      logger.warning('Invalid feed URL: $url');
      throw Exception('Invalid feed URL: $url');
    }

    // Add feed URL to DB
    await _dbProvider.addFeedURL(url);
    logger.info('Feed URL added: $url');

    // Trigger a refresh to include the new feed
    await refreshFeeds();
  }

  @override
  Future<void> removeFeedURL(String url) async {
    logger.info('Removing feed URL: $url');
    await _dbProvider.removeFeedURL(url);
    await _dbProvider.removeFeedCache(url);

    // Update the stream with remaining feeds
    final remainingFeeds = await _getCachedFeeds();
    _feedsStreamController.add(remainingFeeds);
    logger.info('Stream updated after removing feed URL: $url');
  }

  @override
  Stream<List<ParseFeedResponseFeedModel>> getFeedsStream() async* {
    logger.info('getFeedsStream called');

    // First emit cached data
    final cachedFeeds = await _getCachedFeeds();
    logger.info('Emitting ${cachedFeeds.length} cached feeds');
    yield cachedFeeds;

    // Start listening to the controller's stream to get updates
    // This ensures the stream receives both initial data and updates
    await for (final feeds in feedsStream) {
      logger.info('Emitting ${feeds.length} feeds from feedsStream');
      yield feeds;
    }
  }

  @override
  Future<void> refreshFeeds() async {
    logger.info('Refreshing feeds');
    try {
      final freshFeeds = await _fetchFeedsFromNetwork();
      logger.info('Fetched ${freshFeeds.length} fresh feeds from network');

      // Add to the stream controller - this will update all listeners
      _feedsStreamController.add(freshFeeds);
      logger.info('Stream updated with fresh feeds');
    } catch (e, stackTrace) {
      logger.error('Failed to refresh feeds', e, stackTrace);
      rethrow;
    }
  }

  Future<List<ParseFeedResponseFeedModel>> _getCachedFeeds() async {
    logger.info('Getting cached feeds');
    final feedURLs = _dbProvider.getFeedURLs();
    final cachedFeeds = <ParseFeedResponseFeedModel>[];

    for (final feedURL in feedURLs) {
      final cachedFeed = await _dbProvider.getFeedCache(feedURL.url);
      if (cachedFeed != null && !cachedFeed.isError) {
        cachedFeeds.add(cachedFeed.feed.toModel());
      }
    }

    logger.info('Retrieved ${cachedFeeds.length} cached feeds');
    return _orderFeeds(cachedFeeds, feedURLs);
  }

  Future<List<ParseFeedResponseFeedModel>> _fetchFeedsFromNetwork() async {
    logger.info('Fetching feeds from network');
    final feedURLs = _dbProvider.getFeedURLs();
    if (feedURLs.isEmpty) {
      logger.info('No feed URLs to fetch');
      return [];
    }

    try {
      final urlsToFetch = feedURLs.map((item) => item.url).toList();
      logger.info(
        'Fetching ${urlsToFetch.length} feeds: ${urlsToFetch.join(", ")}',
      );

      final parsedFeeds = await _rssLibraryProvider.parseFeedURLs(urlsToFetch);

      // Check response structure and log it for debugging
      logger.info(
        'Parse response status: ${parsedFeeds.status}, errors: ${parsedFeeds.errors.join(", ")}',
      );
      logger.info('Successfully fetched ${parsedFeeds.feeds.length} feeds');

      // Log the data structure we received
      if (parsedFeeds.feeds.isEmpty) {
        logger.warning(
          'No feeds found in the response. This might indicate a structure mismatch.',
        );
      }

      // Cache the successful results
      for (final feed in parsedFeeds.feeds) {
        logger.info('Caching feed: ${feed.url} with title: ${feed.feed.title}');
        await _dbProvider.cacheFeed(
          FeedCacheEntity(
            url: feed.url,
            feed: FeedModelEntity.fromModel(feed),
            lastUpdated: DateTime.now(),
          ),
        );
      }

      return _orderFeeds(parsedFeeds.feeds, feedURLs);
    } catch (e, stackTrace) {
      logger.error('Error fetching feeds from network', e, stackTrace);

      // Cache the error
      for (final feedURL in feedURLs) {
        logger.info('Caching error for feed: ${feedURL.url}');
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
    logger.info(
      'Ordering ${feeds.length} feeds based on ${feedURLs.length} URLs',
    );
    final orderedFeeds = <ParseFeedResponseFeedModel>[];
    for (final feedURL in feedURLs) {
      final feed = feeds.firstWhereOrNull((feed) => feed.url == feedURL.url);
      if (feed != null) {
        orderedFeeds.add(feed);
      }
    }
    logger.info('Returning ${orderedFeeds.length} ordered feeds');
    return orderedFeeds;
  }

  void dispose() {
    logger.info('Disposing DefaultFeedRepository');
    _refreshTimer?.cancel();
    _feedsStreamController.close();
  }
}
