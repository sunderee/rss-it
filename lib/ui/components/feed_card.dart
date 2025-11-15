import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/shared/utilities/extensions.dart';
import 'package:rss_it/ui/components/bottom_sheet/move_feed_bottom_sheet.dart';
import 'package:rss_it/ui/feed_screen.dart';

enum _FeedCardMenuAction { delete, info, move }

final class FeedCard extends StatelessWidget {
  final FeedEntity feed;

  const FeedCard({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    final sanitizedTitle = feed.title.trim();
    final initials = sanitizedTitle.isNotEmpty
        ? sanitizedTitle.substring(0, 1).toUpperCase()
        : '?';
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => FeedScreen.navigateTo(context, feed.id ?? -1, feed.title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: context.theme.colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feed.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.textTheme.titleMedium,
                    ),
                  ),
                  PopupMenuButton<_FeedCardMenuAction>(
                    tooltip: 'Feed actions',
                    onSelected: (action) => _onMenuButtonPressed(context, action),
                    itemBuilder: (context) => const [
                      PopupMenuItem<_FeedCardMenuAction>(
                        value: _FeedCardMenuAction.move,
                        child: Text('Move to folder'),
                      ),
                      PopupMenuItem<_FeedCardMenuAction>(
                        value: _FeedCardMenuAction.info,
                        child: Text('Details'),
                      ),
                      PopupMenuItem<_FeedCardMenuAction>(
                        value: _FeedCardMenuAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              if (feed.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  feed.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                feed.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.textTheme.labelMedium?.copyWith(
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMenuButtonPressed(BuildContext context, _FeedCardMenuAction action) {
    final actionToExecute = switch (action) {
        _FeedCardMenuAction.delete => () => _deleteFeed(context, feed.id),
        _FeedCardMenuAction.info => () => _showFeedInfo(context, feed.id),
        _FeedCardMenuAction.move => () => _moveFeed(context),
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
          children: [
            if (feed.description?.isNotEmpty ?? false) ...[
              Text(feed.description!),
              const SizedBox(height: 8),
            ],
            Text(
              feed.url,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _moveFeed(BuildContext context) {
    if (feed.id == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => MoveFeedBottomSheet(
        feedId: feed.id!,
        feedTitle: feed.title,
        currentFolderId: feed.folderId,
      ),
    );
  }
}
