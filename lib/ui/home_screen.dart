import 'package:flutter/material.dart';
import 'package:rss_it/common/di.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/ui/components/bottom_sheets/add_feed_bottom_sheet.dart';
import 'package:rss_it/ui/components/feed/feed_card.dart';
import 'package:rss_it/ui/feed_screen.dart';
import 'package:rss_it_library/protos/feed.pbenum.dart';

final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends State<HomeScreen> {
  late final FeedNotifier _feedNotifier;

  @override
  void initState() {
    super.initState();
    _feedNotifier = locator.get<FeedNotifier>();
    _feedNotifier.addListener(_feedNotifierListener);
    _feedNotifier.fetchFeeds();
  }

  @override
  void dispose() {
    _feedNotifier.removeListener(_feedNotifierListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.rss_feed,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text('RSSit'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddFeedBottomSheet(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add RSS Feed',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _feedNotifier,
        builder: (context, _) {
          if (_feedNotifier.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final feeds = _feedNotifier.data?.feeds.map((item) => item) ?? [];
          if (feeds.isEmpty) {
            return _buildEmptyState(context);
          }

          final totalItems = feeds.fold<int>(
            0,
            (sum, feed) => sum + feed.items.length,
          );

          return Column(
            children: [
              if (totalItems > 0) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalItems ${totalItems == 1 ? 'article' : 'articles'} across ${feeds.length} ${feeds.length == 1 ? 'feed' : 'feeds'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _feedNotifier.fetchFeeds(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: feeds.length,
                    itemBuilder: (context, index) {
                      final feed = feeds.elementAt(index);
                      return FeedCard(
                        feed: feed,
                        onPressed: () =>
                            FeedScreen.navigateTo(context, feed: feed),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFeedBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Feed'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.rss_feed_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to RSSit!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Stay updated with your favorite content',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Add your first RSS feed to get started with personalized news and updates from your favorite websites.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddFeedBottomSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Feed'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showSampleFeeds(context),
              icon: const Icon(Icons.explore),
              label: const Text('Browse Popular Feeds'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFeedBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const AddFeedBottomSheet(),
    );
  }

  void _showSampleFeeds(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Popular RSS Feeds'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Here are some popular RSS feeds to get you started:'),
              SizedBox(height: 16),
              Text('• BBC News: https://feeds.bbci.co.uk/news/rss.xml'),
              Text('• TechCrunch: https://techcrunch.com/feed/'),
              Text('• The Verge: https://www.theverge.com/rss/index.xml'),
              Text('• Hacker News: https://hnrss.org/frontpage'),
              SizedBox(height: 16),
              Text('Copy any of these URLs and add them as feeds!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddFeedBottomSheet(context);
            },
            child: const Text('Add Feed'),
          ),
        ],
      ),
    );
  }

  void _feedNotifierListener() {
    if (!_feedNotifier.isLoading && _feedNotifier.data != null) {
      if (_feedNotifier.data!.errors.isNotEmpty) {
        final errors = _feedNotifier.data!.errors.join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Some errors occurred while fetching feeds: $errors'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _feedNotifier.fetchFeeds(),
            ),
          ),
        );
        return;
      }

      final statusMessage = switch (_feedNotifier.data!.status) {
        ParseFeedsStatus.SUCCESS => 'Feeds updated successfully',
        ParseFeedsStatus.PARTIAL => 'Some feeds updated successfully',
        ParseFeedsStatus.ERROR => 'Failed to update feeds',
        _ => 'Unknown status',
      };

      if (_feedNotifier.data!.status != ParseFeedsStatus.SUCCESS) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusMessage),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _feedNotifier.fetchFeeds(),
            ),
          ),
        );
      }
    }
  }
}
