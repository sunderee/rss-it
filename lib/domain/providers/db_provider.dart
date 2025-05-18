import 'package:rss_it/domain/data/feed_url.entity.dart';

abstract interface class DBProvider {
  Future<void> addFeedURL(String url);
  List<FeedURLEntity> getFeedURLs();
  Future<void> removeFeedURL(String url);
}
