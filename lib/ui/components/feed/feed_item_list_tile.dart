import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

final class FeedItemListTile extends StatelessWidget {
  final FeedItem item;

  const FeedItemListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
      subtitle: item.description
          .takeIf((it) => it.isNotEmpty)
          ?.let((it) => Text(it, maxLines: 2, overflow: TextOverflow.ellipsis)),
    );
  }
}
