import 'package:rss_it_library/protos/feed.pb.dart';

abstract interface class FeedRepository {
  Future<void> addFeedURL(String url);
  Future<void> removeFeedURL(String url);

  Future<ParseFeedsResponse> fetchFeeds();
}
