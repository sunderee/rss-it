import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';
import 'package:rss_it/hive/hive_registrar.g.dart';

Future<void> initializeDependencies() async {
  // Initialize HiveCE database and register adapters
  Hive
    ..init(Directory.current.path)
    ..registerAdapters();

  // Open HiveCE boxes
  final feedURLBox = await Hive.openBox<FeedURLEntity>('feed_url');
}
