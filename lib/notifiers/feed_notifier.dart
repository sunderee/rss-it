import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:simplest_logger/simplest_logger.dart';

final class FeedNotifier extends ChangeNotifier with SimplestLoggerMixin {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAddingFeed = false;
  bool get isAddingFeed => _isAddingFeed;

  ParseFeedsResponse? _data;
  ParseFeedsResponse? get data => _data;

  final FeedRepository _repository;

  FeedNotifier({required FeedRepository repositoryInstance})
    : _repository = repositoryInstance;

  Future<void> addFeedURL(String url) async {
    _isAddingFeed = true;
    notifyListeners();

    try {
      await _repository.addFeedURL(url);
      fetchFeeds();
    } catch (error, stackTrace) {
      logger.error('Error adding feed URL', error, stackTrace);
    } finally {
      _isAddingFeed = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeeds() async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = await _repository.fetchFeeds();
    } catch (error, stackTrace) {
      logger.error('Error fetching feeds', error, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
