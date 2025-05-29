import 'package:flutter/material.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/shared/utilities/extensions.dart';
import 'package:rss_it/ui/components/bottom_sheet/add_feed_bottom_sheet.dart';
import 'package:rss_it/ui/components/feed_card.dart';

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
    _feedNotifier.getFeeds(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSSit'),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => const AddFeedBottomSheet(),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: _FeedsList(feedNotifier: _feedNotifier),
      ),
    );
  }
}

final class _FeedsList extends StatelessWidget {
  final FeedNotifier feedNotifier;

  const _FeedsList({required this.feedNotifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: feedNotifier,
      builder: (context, _) {
        if (feedNotifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final feeds = feedNotifier.feeds;
        if (feeds.isEmpty) {
          return const _EmptyFeedsContainer();
        }

        return RefreshIndicator(
          onRefresh: () => feedNotifier.getFeeds(),
          child: ListView.builder(
            itemCount: feeds.length,
            itemBuilder: (context, index) {
              final feed = feeds.elementAt(index);
              return FeedCard(feed: feed);
            },
          ),
        );
      },
    );
  }
}

final class _EmptyFeedsContainer extends StatelessWidget {
  const _EmptyFeedsContainer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.media.size.width,
      height: context.media.size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.rss_feed_outlined,
            size: 56.0,
            color: context.theme.colorScheme.primary,
          ),
          Text(
            'Welcome to RSSit!',
            textAlign: TextAlign.center,
            style: context.theme.textTheme.headlineMedium?.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          Text(
            'Add your first RSS feed to get started with personalized news and updates from your favorite websites.',
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodyLarge?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
