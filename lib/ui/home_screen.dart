import 'package:flutter/material.dart';
import 'package:rss_it/common/di.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';

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
  }

  @override
  void dispose() {
    _feedNotifier.removeListener(_feedNotifierListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RSSit')),
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
              return ListTile(
                title: Text(feed.feed.title),
                subtitle: Text(feed.feed.description),
              );
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
