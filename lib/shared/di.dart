import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rss_it/domain/providers/sqlite_db_provider.dart';
import 'package:rss_it/domain/repositories/default_feed_repository.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:simplest_service_locator/simplest_service_locator.dart';
import 'package:sqflite/sqflite.dart';

final SimplestServiceLocator locator = SimplestServiceLocator.instance();

const Map<String, Map<String, String>> _createTableQueries = {
  'feeds': {
    'id': 'integer primary key autoincrement',
    'url': 'text not null',
    'title': 'text not null',
    'description': 'text',
    'thumbnail_url': 'text',
    'added_at': 'datetime not null',
  },
  'feed_items': {
    'id': 'integer primary key autoincrement',
    'feed_id': 'integer not null',
    'link': 'text not null',
    'title': 'text not null',
    'description': 'text',
    'image_url': 'text',
    'published_at': 'datetime',
    'created_at': 'datetime not null',
  },
};

const _createIndexQueries = [
  'create index idx_feed_items_feed_id on feed_items(feed_id);',
  'create index idx_feed_items_created_at on feed_items(created_at);',
  'create index idx_feeds_url on feeds(url);',
  'create index idx_feeds_title on feeds(title);',
  'create index idx_feeds_added_at on feeds(added_at);',
];

Future<void> initializeDependencies() async {
  final databaseInstance = await _initializeDatabase();
  final dbProviderInstance = SQLiteDBProvider(
    databaseInstance: databaseInstance,
  );

  final feedRepository = DefaultFeedRepository(
    dbProviderInstance: dbProviderInstance,
  );
  locator.registerSingleton<FeedNotifier>(
    FeedNotifier(feedRepositoryInstance: feedRepository),
  );
}

Future<Database> _initializeDatabase() async {
  final databasePath = await getApplicationDocumentsDirectory()
      .then((value) => value.path)
      .then((value) => join(value, 'rss_it.db'));
  return openDatabase(
    databasePath,
    version: 1,
    onCreate: (db, _) async {
      // Enforce foreign key constraints
      await db.execute('pragma foreign_keys = on;');

      // Create tables if they don't exist yet
      for (final table in _createTableQueries.entries) {
        final tableName = table.key;
        final columns = table.value.entries
            .map((item) => '${item.key} ${item.value}')
            .join(', ');
        final query = 'create table if not exists $tableName ($columns)';
        await db.execute(query);
      }

      // Create indexes
      for (final index in _createIndexQueries) {
        await db.execute(index);
      }
    },
  );
}
