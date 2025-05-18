import 'package:collection/collection.dart';
import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';

final class HiveDBProvider implements DBProvider {
  final Box<FeedURLEntity> _feedURLsBox;

  HiveDBProvider({required Box<FeedURLEntity> feedURLsBoxInstance})
    : _feedURLsBox = feedURLsBoxInstance;

  @override
  Future<void> addFeedURL(String url) async {
    // Check if box with this URL already exists
    final feedURLExists = _feedURLsBox.values
        .firstWhereOrNull((item) => item.url == url)
        .let((it) => it != null);
    if (feedURLExists) {
      throw Exception('FeedURLEntity with URL $url already exists');
    }

    // Calculate new order
    final newOrder = _feedURLsBox.values.length + 1;
    final newFeedURL = FeedURLEntity(
      url: url,
      order: newOrder,
      added: DateTime.now(),
    );

    // Save to DB
    await _feedURLsBox.put(url, newFeedURL);
  }

  @override
  List<FeedURLEntity> getFeedURLs() => _feedURLsBox.values.sorted(
    (first, second) => first.order.compareTo(second.order),
  );

  @override
  Future<void> removeFeedURL(String url) => _feedURLsBox.delete(url);
}
