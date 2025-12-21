import 'package:flutter/material.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/shared/utilities/extensions.dart';

final class MoveFeedBottomSheet extends StatefulWidget {
  const MoveFeedBottomSheet({
    super.key,
    required this.feedId,
    required this.feedTitle,
    required this.currentFolderId,
  });

  final int feedId;
  final String feedTitle;
  final int? currentFolderId;

  @override
  State<MoveFeedBottomSheet> createState() => _MoveFeedBottomSheetState();
}

final class _MoveFeedBottomSheetState extends State<MoveFeedBottomSheet> {
  late final FeedNotifier _feedNotifier;
  int? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _feedNotifier = locator.get<FeedNotifier>();
    _selectedFolderId = widget.currentFolderId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: context.media.viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move feed',
              style: context.theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.feedTitle,
              style: context.theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: _feedNotifier,
              builder: (context, _) {
                final folders = _feedNotifier.folders.toList();
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: context.media.size.height * 0.4,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      RadioListTile<int?>(
                        value: null,
                        groupValue: _selectedFolderId,
                        title: const Text('Unsorted'),
                        onChanged: (value) =>
                            setState(() => _selectedFolderId = value),
                      ),
                      ...folders.map(
                        (folder) => RadioListTile<int?>(
                          value: folder.id,
                          groupValue: _selectedFolderId,
                          title: Text(folder.name),
                          onChanged: (value) =>
                              setState(() => _selectedFolderId = value),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _applyMove,
                child: const Text('Move feed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyMove() async {
    await _feedNotifier.moveFeedToFolder(
      feedID: widget.feedId,
      folderID: _selectedFolderId,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}
