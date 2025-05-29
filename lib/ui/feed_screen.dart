import 'package:flutter/material.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/ui/components/feed_item_card.dart';

final class FeedScreen extends StatefulWidget {
  static void navigateTo(BuildContext context, int feedID, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FeedScreen(feedID: feedID, title: title),
      ),
    );
  }

  final int feedID;
  final String title;

  const FeedScreen({super.key, required this.feedID, required this.title});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

final class _FeedScreenState extends State<FeedScreen> {
  late final FeedNotifier _feedNotifier;

  @override
  void initState() {
    super.initState();
    _feedNotifier = locator.get<FeedNotifier>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _feedNotifier.loadFeedItems(widget.feedID),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: _feedNotifier,
          builder: (context, _) {
            if (_feedNotifier.isLoadingFeedItems) {
              return const Center(child: CircularProgressIndicator());
            }

            final feedItems = _feedNotifier.feedItems;
            if (feedItems.isEmpty) {
              return const Center(child: Text('No feed items found'));
            }

            return ListView.builder(
              itemCount: feedItems.length,
              itemBuilder: (context, index) {
                final feedItem = feedItems.elementAt(index);
                return FeedItemCard(feedItem: feedItem);
              },
            );
          },
        ),
      ),
    );
  }
}
