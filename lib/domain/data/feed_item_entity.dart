import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

final class FeedItemEntity {
  static FeedItemEntity fromRemoteFeedItem(
    int feedID,
    FeedItem remoteFeedItem,
  ) {
    return FeedItemEntity(
      feedID: feedID,
      link: remoteFeedItem.link,
      title: remoteFeedItem.title,
      description: remoteFeedItem.description,
      imageURL: remoteFeedItem.image,
      publishedAt: DateTime.tryParse(remoteFeedItem.published),
      createdAt: DateTime.now(),
    );
  }

  int? id;
  final int feedID;
  final String link;
  final String title;
  final String? description;
  final String? imageURL;
  final DateTime? publishedAt;
  final DateTime createdAt;

  FeedItemEntity({
    this.id,
    required this.feedID,
    required this.link,
    required this.title,
    required this.description,
    required this.imageURL,
    required this.publishedAt,
    required this.createdAt,
  });

  factory FeedItemEntity.fromJson(Map<String, Object?> json) {
    return FeedItemEntity(
      id: json['id'] as int,
      link: json['link'] as String,
      feedID: json['feed_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageURL: json['image_url'] as String?,
      publishedAt: (json['published_at'] as String?)?.let(
        (it) => DateTime.parse(it),
      ),
      createdAt: (json['created_at'] as String).let((it) => DateTime.parse(it)),
    );
  }

  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'feed_id': feedID,
      'link': link,
      'title': title,
      'description': description,
      'image_url': imageURL,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
