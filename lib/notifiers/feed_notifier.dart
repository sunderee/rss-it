import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/enums.dart';
import 'package:rss_it/domain/data/feed_collection.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/domain/data/folder_entity.dart';
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

  Iterable<FolderEntity> _folders = [];
  Iterable<FolderEntity> get folders => _folders;

  List<FeedCollection> _feedCollections = [];
  List<FeedCollection> get feedCollections => _feedCollections;

  DateTime? _lastRefreshTime;

  FeedNotifier({required FeedRepository feedRepositoryInstance})
    : _feedRepository = feedRepositoryInstance;

  Future<void> getFeeds({bool forceRefresh = false}) async {
    logger.info('Getting feeds...');

    _isLoading = true;
    notifyListeners();

    try {
      await _refreshLocalData();
      logger.info('...feeds from DB count: ${_feeds.length}');
      logger.info('...folders from DB count: ${_folders.length}');

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

      await _refreshLocalData();
      logger.info('...feeds loaded.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> addFeed(String url, {int? folderID}) async {
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
          await _feedRepository.saveFeedToDB(
            feed,
            folderID: folderID,
          );
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

  Future<void> createFolder(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    logger.info('Creating folder ($trimmedName)...');
    _isLoading = true;
    notifyListeners();

    try {
      await _feedRepository.createFolder(trimmedName);
      await _refreshLocalData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> renameFolder({
    required int folderID,
    required String newName,
  }) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    logger.info('Renaming folder ($folderID -> $trimmedName)...');
    _isLoading = true;
    notifyListeners();

    try {
      await _feedRepository.renameFolder(folderID, trimmedName);
      await _refreshLocalData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFolder(int folderID) async {
    logger.info('Deleting folder ($folderID) and contained feeds...');
    _isLoading = true;
    notifyListeners();

    try {
      await _feedRepository.deleteFolder(folderID);
      await _refreshLocalData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveFeedToFolder({
    required int feedID,
    int? folderID,
  }) async {
    logger.info('Moving feed ($feedID) to folder ($folderID)...');
    _isLoading = true;
    notifyListeners();

    try {
      await _feedRepository.moveFeedToFolder(
        feedID: feedID,
        folderID: folderID,
      );
      await _refreshLocalData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetFeedItems() {
    _isLoading = false;
    _isLoadingFeedItems = false;
    _feedValidationStatus = FeedValidationStatus.idle;
    _feedItems = [];
    notifyListeners();
  }

  Future<void> _refreshLocalData() async {
    final foldersInDB = await _feedRepository.getFoldersFromDB();
    final feedsInDB = await _feedRepository.getFeedsFromDB();
    _folders = foldersInDB;
    _feeds = feedsInDB;
    _feedCollections = _buildCollections();
    notifyListeners();
  }

  List<FeedCollection> _buildCollections() {
    final groupedFeeds = <int?, List<FeedEntity>>{};
    for (final feed in _feeds) {
      groupedFeeds.putIfAbsent(feed.folderId, () => []).add(feed);
    }

    final sortedFolders = _folders.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final collections = <FeedCollection>[];
    final unsortedFeeds = groupedFeeds[null] ?? [];
    if (unsortedFeeds.isNotEmpty) {
      collections.add(
        FeedCollection(folder: null, feeds: unsortedFeeds.toList()),
      );
    }

    for (final folder in sortedFolders) {
      final feedsForFolder = groupedFeeds[folder.id] ?? [];
      collections.add(
        FeedCollection(folder: folder, feeds: feedsForFolder.toList()),
      );
    }

    return collections;
  }
}
