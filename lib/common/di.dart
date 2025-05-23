import 'package:hive_ce/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';
import 'package:rss_it/domain/repositories/default_feed_repository.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it/hive/hive_registrar.g.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:simplest_service_locator/simplest_service_locator.dart';

final SimplestServiceLocator locator = SimplestServiceLocator.instance();

Future<void> initializeDependencies() async {
  // Initialize HiveCE database and register adapters
  final applicationDirectory = await getApplicationDocumentsDirectory();
  final hiveDBPath = join(applicationDirectory.path, 'db');
  Hive
    ..init(hiveDBPath)
    ..registerAdapters();

  // Open HiveCE boxes
  final feedURLBox = await Hive.openBox<FeedURLEntity>('feed_url');

  // Repositories
  final FeedRepository feedRepositoryInstance = DefaultFeedRepository(
    feedURLsBoxInstance: feedURLBox,
  );

  // Notifiers
  final FeedNotifier feedNotifierInstance = FeedNotifier(
    repositoryInstance: feedRepositoryInstance,
  );

  // Register notifiers
  locator.registerSingleton<FeedNotifier>(feedNotifierInstance);
}
