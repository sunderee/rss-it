import 'package:flutter/material.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.item.link));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => _copyLink(context),
            icon: const Icon(Icons.copy),
            tooltip: 'Copy link',
          ),
          IconButton(
            onPressed: () => _shareLink(context),
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open_browser',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser),
                    SizedBox(width: 8),
                    Text('Open in browser'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            _buildErrorView(context)
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: colorScheme.surface.withValues(alpha: 0.8),
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load content',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _retryLoading(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _openInBrowser(context),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in browser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    SharePlus.instance.share(
      ShareParams(
        title: widget.item.title,
        uri: Uri.tryParse(widget.item.link),
      ),
    );
  }

  void _shareLink(BuildContext context) {
    // Note: For a real implementation, you'd use the share_plus package
    // For now, we'll just copy to clipboard
    _copyLink(context);
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'refresh':
        _retryLoading();
        break;
      case 'open_browser':
        _openInBrowser(context);
        break;
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _controller.reload();
  }

  void _openInBrowser(BuildContext context) {
    launchUrl(Uri.parse(widget.item.link));
  }
}
