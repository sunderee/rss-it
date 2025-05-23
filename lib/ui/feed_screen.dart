import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:rss_it/ui/feed_item_screen.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

final class FeedScreen extends StatelessWidget {
  static void navigateTo(BuildContext context, {required Feed feed}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => FeedScreen(feed: feed)),
    );
  }

  final Feed feed;

  const FeedScreen({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(feed.title)),
      body: ListView.builder(
        itemCount: feed.items.length,
        itemBuilder: (context, index) {
          final item = feed.items.elementAt(index);
          return ListTile(
            title: Text(item.title),
            subtitle: item.description
                .takeIf((it) => it.isNotEmpty)
                ?.let(
                  (it) =>
                      Text(it, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
            onTap: () => FeedItemScreen.navigateTo(context, item: item),
          );
        },
      ),
    );
  }
}
