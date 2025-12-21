import 'package:collection/collection.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/folder_entity.dart';

final class FeedCollection {
  final FolderEntity? folder;
  final List<FeedEntity> feeds;

  const FeedCollection({
    required this.folder,
    required this.feeds,
  });

  String get displayName =>
      folder?.name ??
      (feeds.isEmpty ? 'Unsorted feeds' : 'Unsorted (${feeds.length})');

  bool get isFolder => folder != null;

  /// Returns feeds sorted alphabetically to offer predictable ordering.
  List<FeedEntity> get sortedFeeds =>
      feeds.sorted((a, b) => a.title.compareTo(b.title));
}
