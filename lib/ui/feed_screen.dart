import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:flutter/material.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:simplest_logger/simplest_logger.dart';

final class FeedScreen extends StatefulWidget {
  static void navigateTo(BuildContext context, {required Feed feed}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => FeedScreen(feed: feed)),
    );
  }

  final Feed feed;

  const FeedScreen({super.key, required this.feed});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

final class _FeedScreenState extends State<FeedScreen>
    with SimplestLoggerMixin {
  @override
  void initState() {
    super.initState();
    logger.info('Displaying ${widget.feed.items.length} feeds');
    for (final item in widget.feed.items) {
      logger.info('Feed item: ${item.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.feed.title)),
      body: ListView.builder(
        itemCount: widget.feed.items.length,
        itemBuilder: (context, index) {
          final item = widget.feed.items.elementAt(index);
          return ListTile(
            title: Text(item.title),
            subtitle: item.description
                .takeIf((it) => it.isNotEmpty)
                ?.let(
                  (it) =>
                      Text(it, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
          );
        },
      ),
    );
  }
}
