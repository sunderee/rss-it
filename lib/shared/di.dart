import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rss_it/domain/providers/sqlite_db_provider.dart';
import 'package:rss_it/domain/repositories/default_feed_repository.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:simplest_service_locator/simplest_service_locator.dart';
import 'package:sqflite/sqflite.dart';

final SimplestServiceLocator locator = SimplestServiceLocator.instance();

const _createTableStatements = [
  '''
  create table if not exists folders (
    id integer primary key autoincrement,
    name text not null,
    created_at datetime not null
  )
  ''',
  '''
  create table if not exists feeds (
    id integer primary key autoincrement,
    folder_id integer references folders(id) on delete set null,
    url text not null,
    title text not null,
    description text,
    thumbnail_url text,
    added_at datetime not null
  )
  ''',
  '''
  create table if not exists feed_items (
    id integer primary key autoincrement,
    feed_id integer not null,
    link text not null,
    title text not null,
    description text,
    image_url text,
    published_at datetime,
    created_at datetime not null,
    foreign key (feed_id) references feeds(id)
  )
  ''',
];

const _createIndexStatements = [
  'create index if not exists idx_folders_name on folders(name);',
  'create index if not exists idx_feed_items_feed_id on feed_items(feed_id);',
  'create index if not exists idx_feed_items_created_at on feed_items(created_at);',
  'create index if not exists idx_feeds_url on feeds(url);',
  'create index if not exists idx_feeds_title on feeds(title);',
  'create index if not exists idx_feeds_added_at on feeds(added_at);',
  'create index if not exists idx_feeds_folder_id on feeds(folder_id);',
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
    version: 2,
    onConfigure: (db) async {
      await db.execute('pragma foreign_keys = on;');
    },
    onCreate: (db, _) async {
      for (final statement in _createTableStatements) {
        await db.execute(statement);
      }

      for (final index in _createIndexStatements) {
        await db.execute(index);
      }
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2 && newVersion >= 2) {
        await _applyV2Migration(db);
      }
    },
  );
}

Future<void> _applyV2Migration(Database db) async {
  await db.execute(_createTableStatements.first);

  final feedColumns = await db.rawQuery('pragma table_info(feeds);');
  final hasFolderColumn = feedColumns.any(
    (column) => column['name'] == 'folder_id',
  );
  if (!hasFolderColumn) {
    await db.execute(
      'alter table feeds add column folder_id integer references folders(id) on delete set null;',
    );
  }

  for (final index in [
    'create index if not exists idx_folders_name on folders(name);',
    'create index if not exists idx_feeds_folder_id on feeds(folder_id);',
  ]) {
    await db.execute(index);
  }
}
