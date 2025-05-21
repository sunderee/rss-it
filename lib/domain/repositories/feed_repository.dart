import 'package:rss_it_library/models/parse_feed_model.dart';

abstract interface class FeedRepository {
  Future<void> addFeedURL(String url);
  Future<void> removeFeedURL(String url);

  /// Returns a stream of feed updates following the Network-Bound Resource pattern.
  /// The stream will emit:
  /// 1. Cached data immediately (if available)
  /// 2. Network data when available
  /// 3. Error if network request fails
  Stream<List<ParseFeedResponseFeedModel>> getFeedsStream();

  /// Forces a refresh of all feeds from the network
  Future<void> refreshFeeds();
}
