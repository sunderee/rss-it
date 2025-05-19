import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_cache.entity.dart';
import 'package:rss_it/domain/data/feed_model.entity.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';

@GenerateAdapters([
  AdapterSpec<FeedURLEntity>(),
  AdapterSpec<FeedCacheEntity>(),
  AdapterSpec<FeedModelEntity>(),
  AdapterSpec<FeedItemEntity>(),
])
part 'hive_adapters.g.dart';
