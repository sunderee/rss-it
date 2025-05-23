import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';

@GenerateAdapters([AdapterSpec<FeedURLEntity>()])
part 'hive_adapters.g.dart';
