import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

final class FeedItemScreen extends StatefulWidget {
  static void navigateTo(BuildContext context, FeedItemEntity feedItem) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => FeedItemScreen(feedItem: feedItem),
      ),
    );
  }

  final FeedItemEntity feedItem;

  const FeedItemScreen({super.key, required this.feedItem});

  @override
  State<FeedItemScreen> createState() => _FeedItemScreenState();
}

final class _FeedItemScreenState extends State<FeedItemScreen> {
  late final WebViewController _controller;
  late final Uri _initialUri;

  @override
  void initState() {
    super.initState();
    _initialUri = Uri.parse(widget.feedItem.link);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final requestedUri = Uri.tryParse(request.url);
            if (requestedUri == null) {
              return NavigationDecision.prevent;
            }
            if (!_isAllowedUri(requestedUri)) {
              _showBlockedNavigationSnackBar();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(_initialUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feedItem.title),
        actions: [
          IconButton(
            onPressed: () => _shareLink(context),
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: () => launchUrl(Uri.parse(widget.feedItem.link)),
            icon: const Icon(Icons.open_in_browser),
              tooltip: 'Open in browser',
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }

  void _shareLink(BuildContext context) {
    SharePlus.instance.share(
      ShareParams(
        title: widget.feedItem.title,
        uri: Uri.tryParse(widget.feedItem.link),
      ),
    );
  }

  bool _isAllowedUri(Uri incoming) =>
      incoming.host == _initialUri.host && incoming.scheme == _initialUri.scheme;

  void _showBlockedNavigationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Navigation blocked. Use the browser button to open external links.',
        ),
      ),
    );
  }
}
