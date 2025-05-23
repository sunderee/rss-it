import 'package:flutter/material.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

final class FeedListTile extends StatelessWidget {
  final Feed feed;

  const FeedListTile({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(feed.title),
      subtitle: Text(
        feed.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
