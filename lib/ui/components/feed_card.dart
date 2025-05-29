import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/ui/feed_screen.dart';

enum _FeedCardMenuAction { delete, info }

final class FeedCard extends StatelessWidget {
  final FeedEntity feed;

  const FeedCard({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16.0),
        onTap: () => FeedScreen.navigateTo(context, feed.id ?? -1, feed.title),
        title: Text(feed.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: feed.description
            ?.takeIf((it) => it.isNotEmpty)
            ?.let(
              (it) => Text(it, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
        trailing: PopupMenuButton<_FeedCardMenuAction>(
          padding: EdgeInsets.zero,
          menuPadding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert),
          onSelected: (action) => _onMenuButtonPressed(context, action),
          itemBuilder: (context) => [
            const PopupMenuItem<_FeedCardMenuAction>(
              value: _FeedCardMenuAction.delete,
              child: Text('Delete'),
            ),
            const PopupMenuItem<_FeedCardMenuAction>(
              value: _FeedCardMenuAction.info,
              child: Text('Info'),
            ),
          ],
        ),
      ),
    );
  }

  void _onMenuButtonPressed(BuildContext context, _FeedCardMenuAction action) {
    final actionToExecute = switch (action) {
      _FeedCardMenuAction.delete => () => _deleteFeed(context, feed.id),
      _FeedCardMenuAction.info => () => _showFeedInfo(context, feed.id),
    };

    actionToExecute.call();
  }

  void _deleteFeed(BuildContext context, int? feedID) {
    if (feedID == null) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete feed'),
        content: const Text('Are you sure you want to delete this feed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              locator.get<FeedNotifier>().removeFeed(feedID);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFeedInfo(BuildContext context, int? feedId) {
    if (feedId == null) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feed.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            ?feed.description
                ?.takeIf((it) => it.isNotEmpty)
                ?.let((it) => Text(it)),
            feed.url.let((it) => Text(it)),
          ],
        ),
      ),
    );
  }
}
