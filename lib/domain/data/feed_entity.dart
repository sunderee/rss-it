import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

final class FeedEntity {
  static FeedEntity fromRemoteFeed(Feed remoteFeed) {
    return FeedEntity(
      url: remoteFeed.url,
      title: remoteFeed.title,
      description: remoteFeed.description,
      thumbnailURL: remoteFeed.image,
      addedAt: DateTime.now(),
    );
  }

  int? id;
  final String url;
  final String title;
  final String? description;
  final String? thumbnailURL;
  final DateTime addedAt;

  FeedEntity({
    this.id,
    required this.url,
    required this.title,
    required this.description,
    required this.thumbnailURL,
    required this.addedAt,
  });

  factory FeedEntity.fromJson(Map<String, Object?> json) {
    return FeedEntity(
      id: json['id'] as int,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailURL: json['thumbnail_url'] as String?,
      addedAt: (json['added_at'] as String).let((it) => DateTime.parse(it)),
    );
  }

  Map<String, Object?> toJson() {
    return {
      if (id != null) 'id': id,
      'url': url,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailURL,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
