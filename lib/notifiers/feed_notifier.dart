import 'package:flutter/material.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';

final class FeedNotifier extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ParseFeedResponseFeedModel> _feeds = [];
  List<ParseFeedResponseFeedModel> get feeds => _feeds;

  final FeedRepository _repository;

  FeedNotifier({required FeedRepository repositoryInstance})
    : _repository = repositoryInstance;

  Future<void> fetchFeeds() async {
    _isLoading = true;
    notifyListeners();

    _feeds = await _repository.getFeeds();
    _isLoading = false;
    notifyListeners();
  }
}
