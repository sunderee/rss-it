import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/enums.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:simplest_logger/simplest_logger.dart';

class FeedNotifier extends ChangeNotifier with SimplestLoggerMixin {
  static const _refreshInterval = Duration(minutes: 1);

  final FeedRepository _feedRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingFeedItems = false;
  bool get isLoadingFeedItems => _isLoadingFeedItems;

  FeedValidationStatus _feedValidationStatus = FeedValidationStatus.idle;
  FeedValidationStatus get feedValidationStatus => _feedValidationStatus;

  Iterable<FeedEntity> _feeds = [];
  Iterable<FeedEntity> get feeds => _feeds;

  Iterable<FeedItemEntity> _feedItems = [];
  Iterable<FeedItemEntity> get feedItems => _feedItems;

  DateTime? _lastRefreshTime;

  FeedNotifier({required FeedRepository feedRepositoryInstance})
    : _feedRepository = feedRepositoryInstance;

  Future<void> getFeeds({bool forceRefresh = false}) async {
    logger.info('Getting feeds...');

    _isLoading = true;
    notifyListeners();

    final everythingInDB = await _feedRepository.getFeedsFromDB();
    _feeds = everythingInDB;
    notifyListeners();
    logger.info('...feeds from DB count: ${_feeds.length}');

    final shouldRefresh = forceRefresh ||
        _lastRefreshTime == null ||
        (DateTime.now().difference(_lastRefreshTime!).inSeconds >
            _refreshInterval.inSeconds);
    if (shouldRefresh) {
      logger.info('...refreshing feeds...');
      final persistedFeedURLs = _feeds.map((item) => item.url);
      if (persistedFeedURLs.isNotEmpty) {
        logger.info('...getting remote feeds...');
        final remoteFeeds = await _feedRepository.getFeedsFromRemote(
          persistedFeedURLs.toList(),
        );
        logger.info('...updating feed items if necessary...');
        await _feedRepository.updatedFeedItemsIfNecessary(remoteFeeds);
        logger.info('...feed items updated if necessary.');
      }

      _lastRefreshTime = DateTime.now();
      logger.info('...last refresh time: $_lastRefreshTime');
    }

    final newFeeds = await _feedRepository.getFeedsFromDB();
    _isLoading = false;
    _feeds = newFeeds;
    notifyListeners();
    logger.info('...feeds loaded.');
  }

  Future<void> loadFeedItems(int feedID) async {
    logger.info('Loading feed items (feedID: $feedID)...');
    _isLoadingFeedItems = true;
    _feedItems = [];
    notifyListeners();

    final feedItems = await _feedRepository.getFeedItemsFromDB(feedID);
    _feedItems = feedItems;
    _isLoadingFeedItems = false;
    notifyListeners();
    logger.info('...feed items loaded.');
  }

  Future<void> addFeed(String url) async {
    logger.info('Adding feed (url: $url)...');
    _isLoading = true;
    _feedValidationStatus = FeedValidationStatus.validationInProgress;
    notifyListeners();

    logger.info('...validating feed...');
    final validationStatus = await _feedRepository.validateFeed(url);
    _feedValidationStatus = validationStatus;
    notifyListeners();

    if (validationStatus == FeedValidationStatus.valid) {
      logger.info('...feed is valid, getting remote feed...');
      final remoteFeed = await _feedRepository.getFeedsFromRemote([url]);
      final feed = remoteFeed.firstOrNull;
      if (feed != null) {
        logger.info('...saving feed to database...');
        await _feedRepository.saveFeedToDB(feed);
        logger.info('...feed saved to database.');
      }
    }

    getFeeds();
  }

  Future<void> removeFeed(int feedID) async {
    logger.info('Removing feed (feedID: $feedID)...');
    _isLoading = true;
    notifyListeners();

    await _feedRepository.deleteFeedFromDB(feedID);
    _isLoading = true;
    notifyListeners();
    logger.info('...feed removed from database.');

    getFeeds();
  }

  void resetFeedItems() {
    _isLoading = false;
    _isLoadingFeedItems = false;
    _feedValidationStatus = FeedValidationStatus.idle;
    _feedItems = [];
    notifyListeners();
  }
}
