import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:rss_it/domain/providers/default_rss_library_provider.dart';
import 'package:rss_it/domain/providers/hive_db_provider.dart';
import 'package:rss_it/domain/providers/rss_library_provider.dart';
import 'package:rss_it/domain/repositories/default_feed_repository.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it/hive/hive_registrar.g.dart';

Future<void> initializeDependencies() async {
  // Initialize HiveCE database and register adapters
  Hive
    ..init(Directory.current.path)
    ..registerAdapters();

  // Open HiveCE boxes
  final feedURLBox = await Hive.openBox<FeedURLEntity>('feed_url');

  // Providers
  final DBProvider dbProviderInstance = HiveDBProvider(
    feedURLsBoxInstance: feedURLBox,
  );
  final RssLibraryProvider rssLibraryProviderInstance =
      DefaultRSSLibraryProvider();

  // Repositories
  final FeedRepository feedRepositoryInstance = DefaultFeedRepository(
    dbProviderInstance: dbProviderInstance,
    rssLibraryProviderInstance: rssLibraryProviderInstance,
  );
}
