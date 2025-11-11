import 'package:collection/collection.dart';
import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:rss_it/domain/data/enums.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/domain/providers/db_provider.dart';
import 'package:rss_it/domain/repositories/feed_repository.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:rss_it_library/rss_it_library.dart' as rss_it_library;
import 'package:simplest_logger/simplest_logger.dart';

final class DefaultFeedRepository
    with SimplestLoggerMixin
    implements FeedRepository {
  final DBProvider _dbProvider;
  final Future<bool> Function(String) _validateFeedURL;
  final Future<ParseFeedsResponse> Function(List<String>) _parseFeedURLs;

  DefaultFeedRepository({
    required DBProvider dbProviderInstance,
    Future<bool> Function(String)? validateFeedURL,
    Future<ParseFeedsResponse> Function(List<String>)? parseFeedURLs,
  }) : _dbProvider = dbProviderInstance,
       _validateFeedURL = validateFeedURL ?? rss_it_library.validateFeedURL,
       _parseFeedURLs = parseFeedURLs ?? rss_it_library.parseFeedURLs;

  @override
  Future<FeedValidationStatus> validateFeed(String url) async {
    logger.info('Validating feed $url...');
    final feedExists = await _dbProvider.feedExistsByURL(url: url);
    if (feedExists) {
      logger.info('...feed $url already exists in the database.');
      return FeedValidationStatus.feedExists;
    }

    final validationStatus = await _validateFeedURL(url);
    logger.info('...feed $url validation status: $validationStatus');
    return validationStatus
        ? FeedValidationStatus.valid
        : FeedValidationStatus.feedInvalid;
  }

  @override
  Future<Iterable<Feed>> getFeedsFromRemote(List<String> urls) async {
    logger.info('Fetching feeds from remote ($urls)...');
    final result = await _parseFeedURLs(urls);

    (switch (result.status) {
      ParseFeedsStatus.SUCCESS => logger.info('...status: successful'),
      ParseFeedsStatus.ERROR => logger.error('...status: error'),
      ParseFeedsStatus.PARTIAL => logger.warning('...status: partial'),
      _ => logger.info('...status: unknown'),
    });
    result.errors
        .takeIf((it) => it.isNotEmpty)
        ?.also((it) => logger.error('...errors: $it'));

    return result.feeds;
  }

  @override
  Future<Iterable<FeedEntity>> getFeedsFromDB() async {
    logger.info('Fetching feeds from database...');
    final result = await _dbProvider.getFeeds();
    logger.info('...feeds count: ${result.length}');

    return result;
  }

  @override
  Future<Iterable<FeedItemEntity>> getFeedItemsFromDB(int feedID) async {
    logger.info('Fetching feed items from database (feedID: $feedID)...');
    final result = await _dbProvider.getFeedItems(feedID: feedID);
    logger.info('...feed items count: ${result.length}');

    return result;
  }

  @override
  Future<void> updatedFeedItemsIfNecessary(
    Iterable<Feed> newRemoteFeeds,
  ) async {
    logger.info('Updating feed items if necessary...');
    final persistedFeeds = await _dbProvider.getFeeds();
    logger.info('...persisted feeds count: ${persistedFeeds.length}');

    for (final persistedFeed in persistedFeeds) {
      logger.info('...processing feed ${persistedFeed.url}...');
      final remoteFeed = newRemoteFeeds.firstWhereOrNull(
        (item) => item.url == persistedFeed.url,
      );
      if (remoteFeed == null) {
        logger.warning(
          '...feed ${persistedFeed.url} not found in new remote feeds.',
        );
        continue;
      }

      final incomingFeedItems = remoteFeed.items.map(
        (item) => FeedItemEntity.fromRemoteFeedItem(persistedFeed.id!, item),
      );
      logger.info('...incoming feed items count: ${incomingFeedItems.length}');
      await _dbProvider.updateFeedItems(
        feedID: persistedFeed.id!,
        incomingFeedItems: incomingFeedItems,
      );
      logger.info('...feed ${persistedFeed.url} found in new remote feeds.');
    }
  }

  @override
  Future<void> saveFeedToDB(Feed remoteFeed) async {
    logger.info('Saving feed to database...');
    final feedEntity = FeedEntity.fromRemoteFeed(remoteFeed);
    final feedID = await _dbProvider.createFeedAndReturnID(feed: feedEntity);
    logger.info('...feed ID: $feedID');

    final feedItemEntities = remoteFeed.items.map(
      (item) => FeedItemEntity.fromRemoteFeedItem(feedID, item),
    );
    logger.info('...feed items count: ${feedItemEntities.length}');
    await _dbProvider.createFeedItems(feedItems: feedItemEntities);
    logger.info('...feed items saved to database.');
  }

  @override
  Future<void> deleteFeedFromDB(int feedID) async {
    logger.info('Deleting feed from database (feedID: $feedID)...');
    await _dbProvider.deleteFeed(feedID: feedID);
    logger.info('...feed deleted from database.');
  }
}
