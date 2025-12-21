import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/domain/data/folder_entity.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

/// Factory functions for creating test data entities and protobuf messages
class MockFactories {
  /// Creates a test FeedEntity with optional overrides
  static FeedEntity createFeedEntity({
    int? id,
    String? url,
    String? title,
    String? description,
    String? thumbnailURL,
    DateTime? addedAt,
    int? folderId,
  }) {
    return FeedEntity(
      id: id,
      url: url ?? 'https://example.com/rss.xml',
      title: title ?? 'Test Feed',
      description: description ?? 'Test Feed Description',
      thumbnailURL: thumbnailURL ?? 'https://example.com/thumbnail.png',
      addedAt: addedAt ?? DateTime(2024, 1, 1),
      folderId: folderId,
    );
  }

  /// Creates a test FeedItemEntity with optional overrides
  static FeedItemEntity createFeedItemEntity({
    int? id,
    int? feedID,
    String? link,
    String? title,
    String? description,
    String? imageURL,
    DateTime? publishedAt,
    DateTime? createdAt,
  }) {
    return FeedItemEntity(
      id: id,
      feedID: feedID ?? 1,
      link: link ?? 'https://example.com/article/1',
      title: title ?? 'Test Article',
      description: description ?? 'Test Article Description',
      imageURL: imageURL ?? 'https://example.com/article-image.png',
      publishedAt: publishedAt ?? DateTime(2024, 1, 1, 12, 0),
      createdAt: createdAt ?? DateTime(2024, 1, 1, 13, 0),
    );
  }

  /// Creates a test Feed protobuf message with optional overrides
  static Feed createFeedProto({
    String? url,
    String? title,
    String? description,
    String? image,
    List<FeedItem>? items,
  }) {
    final feed = Feed()
      ..url = url ?? 'https://example.com/rss.xml'
      ..title = title ?? 'Test Feed'
      ..description = description ?? 'Test Feed Description'
      ..image = image ?? 'https://example.com/thumbnail.png';

    if (items != null) {
      feed.items.addAll(items);
    } else {
      feed.items.add(createFeedItemProto());
    }

    return feed;
  }

  /// Creates a test FeedItem protobuf message with optional overrides
  static FeedItem createFeedItemProto({
    String? title,
    String? description,
    String? link,
    String? image,
    String? published,
  }) {
    final item = FeedItem()
      ..title = title ?? 'Test Article'
      ..description = description ?? 'Test Article Description'
      ..link = link ?? 'https://example.com/article/1'
      ..image = image ?? 'https://example.com/article-image.png'
      ..published = published ?? '2024-01-01T12:00:00Z';

    return item;
  }

  /// Creates a list of test FeedEntity objects
  static List<FeedEntity> createFeedEntities({int count = 3}) {
    return List.generate(
      count,
      (index) => createFeedEntity(
        id: index + 1,
        url: 'https://example.com/rss$index.xml',
        title: 'Test Feed ${index + 1}',
      ),
    );
  }

  static FolderEntity createFolderEntity({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return FolderEntity(
      id: id,
      name: name ?? 'Folder ${id ?? 1}',
      createdAt: createdAt ?? DateTime(2024, 1, 1),
    );
  }

  /// Creates a list of test FeedItemEntity objects
  static List<FeedItemEntity> createFeedItemEntities({
    int feedID = 1,
    int count = 3,
  }) {
    return List.generate(
      count,
      (index) => createFeedItemEntity(
        id: null,
        feedID: feedID,
        link: 'https://example.com/article/${index + 1}',
        title: 'Test Article ${index + 1}',
      ),
    );
  }
}

