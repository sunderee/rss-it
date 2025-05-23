import 'package:flutter/material.dart';
import 'package:rss_it/common/di.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/ui/components/bottom_sheets/add_feed_bottom_sheet.dart';
import 'package:rss_it/ui/components/feed/feed_list_tile.dart';
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

          final feeds = _feedNotifier.data?.feeds.map((item) => item) ?? [];
          if (feeds.isEmpty) {
            return const Center(child: Text('No feeds found'));
          }

          return ListView.builder(
            itemCount: feeds.length,
            itemBuilder: (context, index) {
              final feed = feeds.elementAt(index);
              return FeedListTile(feed: feed);
            },
          );
        },
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
          ),
        );

        return;
      }

      final statusMessage = switch (_feedNotifier.data!.status) {
        ParseFeedsStatus.SUCCESS => 'Feeds fetched successfully',
        ParseFeedsStatus.PARTIAL => 'Feeds fetched partially',
        ParseFeedsStatus.ERROR => 'Some errors occurred while fetching feeds',
        _ => 'Unknown status',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
