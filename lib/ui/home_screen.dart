import 'package:flutter/material.dart';
import 'package:rss_it/common/di.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/ui/components/bottom_sheets/add_feed_bottom_sheet.dart';
import 'package:rss_it/ui/components/feed/feed_list_tile.dart';

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
    _feedNotifier.refreshFeeds();
    _feedNotifier.addListener(_feedNotifierListener);
  }

  @override
  void dispose() {
    _feedNotifier.removeListener(_feedNotifierListener);
    super.dispose();
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
              builder: (context) => const AddFeedBottomSheet(),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _feedNotifier,
        builder: (context, _) {
          if (_feedNotifier.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (_feedNotifier.feeds.isEmpty) {
            return const Center(child: Text('No feeds found'));
          }

          return ListView.builder(
            itemCount: _feedNotifier.feeds.length,
            itemBuilder: (context, index) {
              final feed = _feedNotifier.feeds[index];
              return FeedListTile(feed: feed.feed);
            },
          );
        },
      ),
    );
  }

  void _feedNotifierListener() {
    final error = _feedNotifier.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
