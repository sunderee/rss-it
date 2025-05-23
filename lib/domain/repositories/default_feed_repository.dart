import 'package:hive_ce/hive.dart';
import 'package:rss_it/domain/data/feed_url.entity.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:rss_it_library/rss_it_library.dart';
import 'package:simplest_logger/simplest_logger.dart';

final class DefaultFeedRepository
    with SimplestLoggerMixin
    implements FeedRepository {
  final Box<FeedURLEntity> _feedURLsBox;

  DefaultFeedRepository({required Box<FeedURLEntity> feedURLsBoxInstance})
    : _feedURLsBox = feedURLsBoxInstance;

  @override
  Future<void> addFeedURL(String url) async {
    final urlExists = _feedURLsBox.values.any((item) => item.url == url);
    if (urlExists) {
      logger.warning('URL already exists: $url');
      return;
    }

    final isFeedValid = await validateFeedURL(url);
    if (!isFeedValid) {
      logger.warning('Invalid feed URL: $url');
      return;
    }

    final feedURLs = _feedURLsBox.values.toList();
    final order = feedURLs.isEmpty
        ? 0
        : feedURLs.map((item) => item.order).reduce((a, b) => a > b ? a : b) +
              1;
    logger.info('Adding new feed URL: $url with order: $order');

    await _feedURLsBox.put(
      url,
      FeedURLEntity(url: url, order: order, added: DateTime.now()),
    );
  }

  @override
  Future<void> removeFeedURL(String url) async {
    await _feedURLsBox.delete(url);
  }

  @override
  Future<ParseFeedsResponse> fetchFeeds() async {
    final feedURLs = _feedURLsBox.values.toList();
    final feedURLsString = feedURLs.map((item) => item.url).toList();
    final parseFeedsResponse = await parseFeedURLs(feedURLsString);

    logger.info('Parsed feeds: ${parseFeedsResponse.feeds.length}');
    return parseFeedsResponse;
  }
}
