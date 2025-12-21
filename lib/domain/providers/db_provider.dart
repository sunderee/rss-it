import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/domain/data/folder_entity.dart';

enum GetFeedsOrderBy { title, addedAt }

enum OrderByDirection { ascending, descending }

abstract interface class DBProvider {
  Future<bool> feedExistsByURL({required String url});

  Future<int> createFeedAndReturnID({required FeedEntity feed});
  Future<void> createFeedItems({required Iterable<FeedItemEntity> feedItems});

  Future<void> updateFeedItems({
    required int feedID,
    required Iterable<FeedItemEntity> incomingFeedItems,
  });

  Future<Iterable<FolderEntity>> getFolders({
    OrderByDirection orderByDirection = OrderByDirection.ascending,
  });

  Future<int> createFolder({required FolderEntity folder});
  Future<void> renameFolder({
    required int folderID,
    required String newName,
  });

  Future<void> deleteFolder({required int folderID});
  Future<void> moveFeedToFolder({required int feedID, int? folderID});

  Future<Iterable<FeedEntity>> getFeeds({
    int? folderID,
    GetFeedsOrderBy orderBy = GetFeedsOrderBy.title,
    OrderByDirection orderByDirection = OrderByDirection.ascending,
  });
  Future<Iterable<FeedItemEntity>> getFeedItems({required int feedID});

  Future<void> deleteFeed({required int feedID});
}
