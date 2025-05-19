import 'package:rss_it_library/models/parse_feed_model.dart';

abstract interface class FeedRepository {
  Future<void> addFeedURL(String url);
  Future<void> removeFeedURL(String url);

  Future<List<ParseFeedResponseFeedModel>> getFeeds();
}
