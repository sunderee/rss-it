import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it/ui/feed_item_screen.dart';

final class FeedItemCard extends StatelessWidget {
  final FeedItemEntity feedItem;

  const FeedItemCard({super.key, required this.feedItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: () => FeedItemScreen.navigateTo(context, feedItem),
        title: Text(feedItem.title),
        subtitle: feedItem.description
            ?.takeIf((it) => it.isNotEmpty)
            ?.let(
              (it) => Text(it, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
      ),
    );
  }
}
