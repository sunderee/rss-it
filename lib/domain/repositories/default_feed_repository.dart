import 'package:collection/collection.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:rss_it/domain/providers/rss_library_provider.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';

final class DefaultFeedRepository implements FeedRepository {
  final DBProvider _dbProvider;
  final RssLibraryProvider _rssLibraryProvider;

  DefaultFeedRepository({
    required DBProvider dbProviderInstance,
    required RssLibraryProvider rssLibraryProviderInstance,
  }) : _dbProvider = dbProviderInstance,
       _rssLibraryProvider = rssLibraryProviderInstance;

  @override
  Future<void> addFeedURL(String url) async {
    // Validate feed URL
    final isFeedURLValid = await _rssLibraryProvider.validateFeedURL(url);
    if (!isFeedURLValid) {
      throw Exception('Invalid feed URL: $url');
    }

    // Add feed URL to DB
    await _dbProvider.addFeedURL(url);
  }

  @override
  Future<void> removeFeedURL(String url) => _dbProvider.removeFeedURL(url);

  @override
  Future<List<ParseFeedResponseFeedModel>> getFeeds() async {
    // Get feed URLs from local persistence
    final feedURLs = _dbProvider.getFeedURLs();

    // Parse feeds
    final parsedFeeds = await _rssLibraryProvider.parseFeedURLs(
      feedURLs.map((item) => item.url).toList(),
    );

    // Order feeds by feed URL
    final orderedFeeds = <ParseFeedResponseFeedModel>[];
    for (final feedURL in feedURLs) {
      final parsedFeed = parsedFeeds.feeds.firstWhereOrNull(
        (feed) => feed.url == feedURL.url,
      );
      if (parsedFeed != null) {
        orderedFeeds.add(parsedFeed);
      }
    }

    return orderedFeeds;
  }
}
