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
  late final FeedNotifier _feedNotifier;

  @override
  void initState() {
    super.initState();
    _animationController = BottomSheet.createAnimationController(this);
    _controller = TextEditingController();

    _feedNotifier = locator.get<FeedNotifier>();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      animationController: _animationController,
      showDragHandle: true,
      enableDrag: true,
      onClosing: () {
        _animationController.reverse();
      },
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter feed URL below. We will perform additional validation.',
              ),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(hintText: 'URL'),
                onSubmitted: (value) {
                  _feedNotifier.attemptToAddFeed(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
