import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rss_it/ui/components/buttons/stateful_button.dart';

void main() {
  group('StatefulButton', () {
    testWidgets('renders enabled button with text', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulButton(
              state: StatefulButtonState.enabled,
              text: 'Test Button',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders disabled button', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulButton(
              state: StatefulButtonState.disabled,
              text: 'Disabled Button',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Disabled Button'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('renders loading button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulButton(
              state: StatefulButtonState.loading,
              text: 'Loading Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Loading Button'), findsNothing);
      expect(find.byType(FilledButton), findsOneWidget);
      // LoadingIndicator is from external package, just verify button exists

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('button has full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulButton(
              state: StatefulButtonState.enabled,
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.style?.fixedSize, isNotNull);
    });
  });
}

