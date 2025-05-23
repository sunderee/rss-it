import 'package:flutter/material.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:webview_flutter/webview_flutter.dart';

final class FeedItemScreen extends StatefulWidget {
  static void navigateTo(BuildContext context, {required FeedItem item}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => FeedItemScreen(item: item)),
    );
  }

  final FeedItem item;

  const FeedItemScreen({super.key, required this.item});

  @override
  State<FeedItemScreen> createState() => _FeedItemScreenState();
}

final class _FeedItemScreenState extends State<FeedItemScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.item.link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
