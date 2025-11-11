import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper functions for widget testing

class WidgetTestHelpers {
  /// Creates a MaterialApp wrapper for testing widgets
  static Widget createTestApp({required Widget child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Creates a MaterialApp with the app theme for testing
  static Widget createThemedTestApp({required Widget child}) {
    return MaterialApp(
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF007AFF),
        ),
      ),
      darkTheme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF0A84FF),
        ),
      ),
      home: Scaffold(body: child),
    );
  }

  /// Pumps a widget with MaterialApp wrapper
  static Future<void> pumpWidgetWithApp(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  }

  /// Pumps a widget with MaterialApp and theme
  static Future<void> pumpWidgetWithTheme(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(createThemedTestApp(child: widget));
  }

  /// Finds a widget by type and optional matcher
  static Finder findWidgetByType<T extends Widget>({Matcher? matcher}) {
    if (matcher != null) {
      return find.byWidgetPredicate(
        (widget) => widget is T && matcher.matches(widget, {}),
      );
    }
    return find.byType(T);
  }

  /// Waits for async operations to complete
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Taps a widget and waits for animations/async operations
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Enters text into a TextField and waits
  static Future<void> enterTextAndWait(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Scrolls a widget and waits
  static Future<void> scrollAndWait(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}
