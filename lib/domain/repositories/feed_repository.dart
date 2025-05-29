import 'package:rss_it/domain/data/enums.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

abstract interface class FeedRepository {
  Future<FeedValidationStatus> validateFeed(String url);

  Future<Iterable<Feed>> getFeedsFromRemote(List<String> urls);
  Future<Iterable<FeedEntity>> getFeedsFromDB();
  Future<Iterable<FeedItemEntity>> getFeedItemsFromDB(int feedID);

  Future<void> updatedFeedItemsIfNecessary(Iterable<Feed> newRemoteFeeds);

  Future<void> saveFeedToDB(Feed remoteFeed);
  Future<void> deleteFeedFromDB(int feedID);
}
