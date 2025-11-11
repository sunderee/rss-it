import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Helper for creating in-memory SQLite databases for testing
class TestDatabase {
  /// Initialize sqflite_ffi for testing
  static void initialize() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  /// Creates an in-memory database with the same schema as the production database
  static Future<Database> createInMemoryDatabase() async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, _) async {
        // Enforce foreign key constraints
        await db.execute('pragma foreign_keys = on;');

        // Create tables
        await db.execute('''
          create table if not exists feeds (
            id integer primary key autoincrement,
            url text not null,
            title text not null,
            description text,
            thumbnail_url text,
            added_at datetime not null
          )
        ''');

        await db.execute('''
          create table if not exists feed_items (
            id integer primary key autoincrement,
            feed_id integer not null,
            link text not null,
            title text not null,
            description text,
            image_url text,
            published_at datetime,
            created_at datetime not null,
            foreign key (feed_id) references feeds(id) on delete cascade
          )
        ''');

        // Create indexes
        await db.execute(
          'create index idx_feed_items_feed_id on feed_items(feed_id);',
        );
        await db.execute(
          'create index idx_feed_items_created_at on feed_items(created_at);',
        );
        await db.execute('create index idx_feeds_url on feeds(url);');
        await db.execute('create index idx_feeds_title on feeds(title);');
        await db.execute('create index idx_feeds_added_at on feeds(added_at);');
      },
    );

    return db;
  }

  /// Creates a temporary file-based database for testing
  static Future<Database> createTempDatabase() async {
    final dbPath = path.join(await getDatabasesPath(), 'test_rss_it.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) async {
        // Enforce foreign key constraints
        await db.execute('pragma foreign_keys = on;');

        // Create tables
        await db.execute('''
          create table if not exists feeds (
            id integer primary key autoincrement,
            url text not null,
            title text not null,
            description text,
            thumbnail_url text,
            added_at datetime not null
          )
        ''');

        await db.execute('''
          create table if not exists feed_items (
            id integer primary key autoincrement,
            feed_id integer not null,
            link text not null,
            title text not null,
            description text,
            image_url text,
            published_at datetime,
            created_at datetime not null,
            foreign key (feed_id) references feeds(id) on delete cascade
          )
        ''');

        // Create indexes
        await db.execute(
          'create index idx_feed_items_feed_id on feed_items(feed_id);',
        );
        await db.execute(
          'create index idx_feed_items_created_at on feed_items(created_at);',
        );
        await db.execute('create index idx_feeds_url on feeds(url);');
        await db.execute('create index idx_feeds_title on feeds(title);');
        await db.execute('create index idx_feeds_added_at on feeds(added_at);');
      },
    );
  }

  /// Cleans up a temporary database file
  static Future<void> deleteTempDatabase() async {
    final dbPath = path.join(await getDatabasesPath(), 'test_rss_it.db');
    await deleteDatabase(dbPath);
  }
}
