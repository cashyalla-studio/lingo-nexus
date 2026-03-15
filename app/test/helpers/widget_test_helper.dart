import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in a minimal ProviderScope + MaterialApp for widget tests.
/// Uses a dark theme (matching the app) and English locale by default.
Widget wrapWithApp(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: ThemeData.dark(),
      home: child,
    ),
  );
}

/// Pumps [widget] and waits for all pending microtasks + timers up to [timeout].
Future<void> pumpAndSettle(
  WidgetTester tester,
  Widget widget, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle(timeout);
}
