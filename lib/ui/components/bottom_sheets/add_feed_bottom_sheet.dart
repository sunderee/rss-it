import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rss_it/common/di.dart';
import 'package:rss_it/notifiers/feed_notifier.dart';

final class AddFeedBottomSheet extends StatefulWidget {
  const AddFeedBottomSheet({super.key});

  @override
  State<AddFeedBottomSheet> createState() => _AddFeedBottomSheetState();
}

final class _AddFeedBottomSheetState extends State<AddFeedBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final FeedNotifier _feedNotifier;

  bool _isSubmitting = false;
  bool? _isValidUrl;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _animationController = BottomSheet.createAnimationController(this);
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _feedNotifier = locator.get<FeedNotifier>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      animationController: _animationController,
      showDragHandle: true,
      enableDrag: !_isSubmitting,
      onClosing: () {
        _animationController.reverse();
      },
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rss_feed,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Add RSS Feed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Enter a valid RSS feed URL. We\'ll validate it before adding.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                decoration: InputDecoration(
                  labelText: 'RSS Feed URL',
                  hintText: 'https://example.com/rss.xml',
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                  errorText: _validationError,
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canSubmit ? _submitUrl : null,
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isSubmitting ? 'Adding Feed...' : 'Add Feed'),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty &&
      !_isSubmitting &&
      _isValidUrl == true;

  void _onUrlChanged(String value) {
    if (value.trim().isEmpty) {
      _resetValidation();
      return;
    }

    final isValid = value.isNotEmpty;
    setState(() {
      _isValidUrl = isValid;
      _validationError = isValid ? null : 'Invalid RSS feed URL';
    });
  }

  void _resetValidation() {
    setState(() {
      _isValidUrl = null;
      _validationError = null;
    });
  }

  Future<void> _submitUrl() async {
    if (!_canSubmit) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _feedNotifier.addFeedURL(_controller.text.trim());
    Navigator.of(context).pop();
  }
}
