import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets a consistent viewport size for widget tests.
/// Automatically resets the surface size in tearDown.
Future<void> setTestViewport(
  WidgetTester tester, {
  Size size = const Size(600, 1000),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Phone viewport (iPhone 14 dimensions).
Future<void> setPhoneViewport(WidgetTester tester) =>
    setTestViewport(tester, size: const Size(390, 844));

/// Tablet viewport (iPad dimensions).
Future<void> setTabletViewport(WidgetTester tester) =>
    setTestViewport(tester, size: const Size(820, 1180));

/// Desktop viewport (MacBook dimensions).
Future<void> setDesktopViewport(WidgetTester tester) =>
    setTestViewport(tester, size: const Size(1440, 900));

/// Wraps a widget in MaterialApp + ProviderScope for testing.
///
/// Pass Riverpod overrides via [overrides]. The list type is `dynamic`
/// because Riverpod's `Override` sealed class is not publicly exported.
/// Callers pass the result of `.overrideWithValue()` / `.overrideWith()`
/// which are already typed correctly at the call site.
Widget buildTestWidget(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(home: child),
  );
}

/// Pumps a test widget and settles animations.
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget child, {
  List<dynamic> overrides = const [],
  Duration? duration,
}) async {
  await tester.pumpWidget(buildTestWidget(child, overrides: overrides));
  if (duration != null) {
    await tester.pump(duration);
  } else {
    await tester.pumpAndSettle();
  }
}
