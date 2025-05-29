import 'package:flutter/material.dart';
import 'package:new_loading_indicator/new_loading_indicator.dart';
import 'package:rss_it/shared/utilities/extensions.dart';

enum StatefulButtonState { enabled, disabled, loading }

final class StatefulButton extends StatelessWidget {
  final StatefulButtonState state;
  final String text;
  final VoidCallback onPressed;

  const StatefulButton({
    super.key,
    required this.state,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        fixedSize: Size.fromWidth(context.media.size.width),
      ),
      onPressed: state == StatefulButtonState.enabled ? onPressed : null,
      child: switch (state) {
        StatefulButtonState.enabled ||
        StatefulButtonState.disabled => Text(text),
        StatefulButtonState.loading => SizedBox(
          height: 24.0,
          width: 24.0,
          child: LoadingIndicator(
            indicatorType: Indicator.ballBeat,
            colors: [context.theme.colorScheme.primary],
          ),
        ),
      },
    );
  }
}
