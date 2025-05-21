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

  FeedNotifier({required FeedRepository repositoryInstance})
    : _repository = repositoryInstance {
    _setupFeedsStream();
  }

  @override
  void dispose() {
    _feedsSubscription?.cancel();
    super.dispose();
  }

  Future<void> refreshFeeds() async {
    logger.warning('Refreshing feeds');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.refreshFeeds();
    } catch (error, stackTrace) {
      logger.error('Error refreshing feeds', error, stackTrace);
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> attemptToAddFeed(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addFeedURL(url);
      refreshFeeds();
    } catch (error, stackTrace) {
      logger.error('Error adding feed', error, stackTrace);
      _error = error.toString();
    }
  }

  void _setupFeedsStream() {
    logger.info('Setting up feeds stream');

    _feedsSubscription?.cancel();
    _feedsSubscription = _repository.getFeedsStream().listen(
      (newFeeds) {
        _feeds = newFeeds;
        _error = null;
        notifyListeners();
      },
      onError: (dynamic error) {
        logger.error('Error in feeds stream', error);
        _error = error.toString();
        notifyListeners();
      },
    );
  }
}
