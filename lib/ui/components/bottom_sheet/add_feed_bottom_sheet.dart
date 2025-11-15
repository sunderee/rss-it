import 'package:flutter/material.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';
import 'package:rss_it/shared/di.dart';
import 'package:rss_it/shared/utilities/extensions.dart';
import 'package:rss_it/ui/components/buttons/stateful_button.dart';
import 'package:rss_it/ui/components/bottom_sheet/manage_folders_bottom_sheet.dart';

final class AddFeedBottomSheet extends StatefulWidget {
  const AddFeedBottomSheet({super.key, this.initialFolderId});

  final int? initialFolderId;

  @override
  State<AddFeedBottomSheet> createState() => _AddFeedBottomSheetState();
}

final class _AddFeedBottomSheetState extends State<AddFeedBottomSheet>
    with SingleTickerProviderStateMixin {
  late final FeedNotifier _feedNotifier;

  late final AnimationController _animationController;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _isSubmitting = false;
  bool? _isValidUrl;
  int? _selectedFolderId;

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty &&
      !_isSubmitting &&
      _isValidUrl == true;

  @override
  void initState() {
    super.initState();
    _feedNotifier = locator.get<FeedNotifier>();

    _animationController = BottomSheet.createAnimationController(this);
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _selectedFolderId = widget.initialFolderId;
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      animationController: _animationController,
      showDragHandle: true,
      enableDrag: true,
      onClosing: () {
        _animationController.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      },
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 16.0,
            bottom: context.media.viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add RSS Feed',
                style: context.theme.textTheme.headlineSmall?.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Enter a valid RSS feed URL. We will validate it before adding it to your collection.',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.url,
                enabled: !_isSubmitting,
                onChanged: _onUrlChanged,
                onSubmitted: (_) => _submitUrl(),
                decoration: const InputDecoration(
                  labelText: 'RSS Feed URL',
                  hintText: 'https://example.com/rss.xml',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
              ),
                const SizedBox(height: 16.0),
                ListenableBuilder(
                  listenable: _feedNotifier,
                  builder: (context, _) {
                    final folders = _feedNotifier.folders.toList();
                    final entries = [
                      const DropdownMenuEntry<int?>(
                        value: null,
                        label: 'No folder',
                      ),
                      ...folders.map(
                        (folder) => DropdownMenuEntry<int?>(
                          value: folder.id,
                          label: folder.name,
                        ),
                      ),
                    ];
                    return DropdownMenu<int?>(
                      leadingIcon: const Icon(Icons.folder_open),
                      label: const Text('Folder (optional)'),
                      textStyle: context.theme.textTheme.bodyLarge,
                      dropdownMenuEntries: entries,
                      initialSelection: _selectedFolderId,
                      onSelected: (value) =>
                          setState(() => _selectedFolderId = value),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _openFolderManager,
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: const Text('Manage folders'),
                  ),
                ),
                const SizedBox(height: 8.0),
              StatefulButton(
                state: _isSubmitting
                    ? StatefulButtonState.loading
                    : _isValidUrl == true
                    ? StatefulButtonState.enabled
                    : StatefulButtonState.disabled,
                text: 'Add Feed',
                onPressed: _submitUrl,
              ),
            ],
          ),
        );
      },
    );
  }

  void _onUrlChanged(String value) {
    if (value.trim().isEmpty) {
      _resetValidation();
      return;
    }

    final isValid = value.isNotEmpty;
    setState(() => _isValidUrl = isValid);
  }

  Future<void> _submitUrl() async {
    if (!_canSubmit) {
      return;
    }

    setState(() => _isSubmitting = true);
    _feedNotifier
        .addFeed(
          _controller.text.trim(),
          folderID: _selectedFolderId,
        )
        .then((_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _animationController.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  void _resetValidation() => setState(() => _isValidUrl = null);

  void _openFolderManager() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const ManageFoldersBottomSheet(),
    );
  }
}
