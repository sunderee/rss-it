import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_model.entity.dart';

final class FeedCacheEntity extends HiveObject {
  final String url;
  final FeedModelEntity feed;
  final DateTime lastUpdated;
  final bool isError;
  final String? errorMessage;

  FeedCacheEntity({
    required this.url,
    required this.feed,
    required this.lastUpdated,
    this.isError = false,
    this.errorMessage,
  });
}
