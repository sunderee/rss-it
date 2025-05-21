import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';
import 'package:simplest_logger/simplest_logger.dart';

final class FeedNotifier extends ChangeNotifier with SimplestLoggerMixin {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ParseFeedResponseFeedModel> _feeds = [];
  List<ParseFeedResponseFeedModel> get feeds => _feeds;

  String? _error;
  String? get error => _error;

  final FeedRepository _repository;
  StreamSubscription<List<ParseFeedResponseFeedModel>>? _feedsSubscription;
  bool _isRefreshing = false; // Guard against multiple concurrent refresh calls

  FeedNotifier({required FeedRepository repositoryInstance})
    : _repository = repositoryInstance {
    _setupFeedsStream();
    logger.info('FeedNotifier initialized, stream setup complete');
    // Initial refresh to load the latest data
    refreshFeeds();
  }

  @override
  void dispose() {
    logger.info('Disposing FeedNotifier');
    _feedsSubscription?.cancel();
    super.dispose();
  }

  /// Updates loading state and notifies listeners in a safe way
  void _setLoading(bool isLoading) {
    if (_isLoading != isLoading) {
      _isLoading = isLoading;
      notifyListeners();
      logger.info('Loading state updated to: $_isLoading');
    }
  }

  Future<void> refreshFeeds() async {
    // Prevent multiple concurrent refreshes
    if (_isRefreshing) {
      logger.warning('Refresh already in progress, ignoring new request');
      return;
    }

    logger.info('Refreshing feeds');
    _isRefreshing = true;
    _setLoading(true);
    _error = null;

    try {
      await _repository.refreshFeeds();
      logger.info('Repository refresh completed');
    } catch (error, stackTrace) {
      logger.error('Error refreshing feeds', error, stackTrace);
      _error = error.toString();
      notifyListeners(); // Ensure UI is updated in case of error
    } finally {
      _isRefreshing = false;
      _setLoading(false);
      logger.info(
        'Feed refresh completed, loading: $_isLoading, error: ${_error != null}',
      );
    }
  }

  Future<void> attemptToAddFeed(String url) async {
    logger.info('Attempting to add feed: $url');
    _setLoading(true);
    _error = null;

    try {
      await _repository.addFeedURL(url);
      logger.info('Feed added successfully: $url');
    } catch (error, stackTrace) {
      logger.error('Error adding feed', error, stackTrace);
      _error = error.toString();
      notifyListeners(); // Ensure UI is updated in case of error
    } finally {
      _setLoading(false);
    }
  }

  void _setupFeedsStream() {
    logger.info('Setting up feeds stream');

    _feedsSubscription?.cancel();
    _feedsSubscription = _repository.getFeedsStream().listen(
      (newFeeds) {
        logger.info('Received ${newFeeds.length} feeds from stream');
        _feeds = newFeeds;
        _error = null;

        // Only update loading state if a refresh isn't actively in progress
        // This prevents stream updates from interfering with manual operations
        if (!_isLoading) {
          notifyListeners();
          logger.info('Feed state updated, notified listeners');
        } else {
          logger.info(
            'Feed state updated but not notifying as loading is in progress',
          );
        }
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        logger.error('Error in feeds stream', error, stackTrace);
        _error = error.toString();

        // Always notify on errors regardless of loading state
        notifyListeners();
        logger.info('Feed error state updated, notified listeners');
      },
    );
  }
}
