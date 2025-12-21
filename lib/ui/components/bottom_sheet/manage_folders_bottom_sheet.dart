import 'package:flutter/material.dart';
import 'package:rss_it/domain/data/folder_entity.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/shared/utilities/extensions.dart';

final class ManageFoldersBottomSheet extends StatefulWidget {
  const ManageFoldersBottomSheet({super.key});

  @override
  State<ManageFoldersBottomSheet> createState() =>
      _ManageFoldersBottomSheetState();
}

final class _ManageFoldersBottomSheetState
    extends State<ManageFoldersBottomSheet> {
  late final FeedNotifier _feedNotifier;
  late final TextEditingController _controller;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _feedNotifier = locator.get<FeedNotifier>();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage folders',
                    style: context.theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Removing a folder permanently deletes all feeds and '
                      'their cached items inside it.',
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: _feedNotifier,
              builder: (context, _) {
                final folders = _feedNotifier.folders.toList();
                if (folders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No folders yet. Create one to get started.',
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: context.media.size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      final feedCount = _feedNotifier.feeds
                          .where((feed) => feed.folderId == folder.id)
                          .length;
                      return ListTile(
                        title: Text(folder.name),
                        subtitle: Text(
                          '$feedCount feed${feedCount == 1 ? '' : 's'}',
                        ),
                        leading: const Icon(Icons.folder),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Rename folder',
                              onPressed: () => _renameFolder(folder),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Delete folder',
                              onPressed: () => _confirmDelete(folder),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _createFolder(),
              decoration: const InputDecoration(
                labelText: 'Folder name',
                prefixIcon: Icon(Icons.create_new_folder_outlined),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _createFolder,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      )
                    : const Text('Create folder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFolder() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() => _isSubmitting = true);
    await _feedNotifier.createFolder(name);
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
      _controller.clear();
    });
  }

  Future<void> _renameFolder(FolderEntity folder) async {
    final renameController = TextEditingController(text: folder.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename folder'),
        content: TextField(
          controller: renameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(renameController.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    renameController.dispose();
    if (result == null || result.trim().isEmpty) {
      return;
    }
    await _feedNotifier.renameFolder(folderID: folder.id!, newName: result);
  }

  Future<void> _confirmDelete(FolderEntity folder) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete folder'),
            content: Text(
              'Delete "${folder.name}" and every feed inside it? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }
    await _feedNotifier.deleteFolder(folder.id!);
  }
}
