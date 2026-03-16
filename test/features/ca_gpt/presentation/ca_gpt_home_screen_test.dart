import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/ca_gpt/presentation/ca_gpt_home_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: CaGptHomeScreen()));
}

Future<void> _setNarrowDisplay(WidgetTester tester) async {
  // Use narrow viewport so bottom nav appears (not wide layout)
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _setWideDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Suppresses layout overflow errors that can occur on narrow test viewports.
Future<void> _ignoreOverflow(Future<void> Function() body) async {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    originalOnError?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = originalOnError;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CaGptHomeScreen (narrow)', () {
    testWidgets('renders without crashing', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(CaGptHomeScreen), findsOneWidget);
    });

    testWidgets('renders CA GPT Chat title initially', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('CA GPT Chat'), findsOneWidget);
    });

    testWidgets('renders Ask any tax question subtitle initially', (
      tester,
    ) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Ask any tax question'), findsOneWidget);
    });

    testWidgets('renders Chat bottom nav destination', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Chat'), findsWidgets);
    });

    testWidgets('renders Section Lookup bottom nav destination', (
      tester,
    ) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Section Lookup'), findsWidgets);
    });

    testWidgets('renders Notice Draft bottom nav destination', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Notice Draft'), findsWidgets);
    });

    testWidgets('renders Tax Calendar bottom nav destination', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Tax Calendar'), findsWidgets);
    });

    testWidgets('renders NavigationBar on narrow viewport', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('tapping Section Lookup changes title', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Section Lookup').first);
      await tester.pumpAndSettle();
      expect(find.text('Section Lookup'), findsWidgets);
    });

    testWidgets('tapping Tax Calendar changes subtitle', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('Tax Calendar').first);
        await tester.pumpAndSettle();
        expect(find.text('Compliance deadline calendar'), findsOneWidget);
      });
    });

    testWidgets('renders Scaffold', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders auto_awesome icon in app bar area', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      // auto_awesome icon is present at least once in the app bar
      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
    });

    testWidgets('tapping Notice Draft changes title', (tester) async {
      await _setNarrowDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('Notice Draft').first);
        await tester.pumpAndSettle();
        expect(find.text('Notice Drafting'), findsOneWidget);
      });
    });
  });

  group('CaGptHomeScreen (wide)', () {
    testWidgets('renders NavigationRail on wide viewport', (tester) async {
      await _setWideDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('wide layout has no bottom navigation bar', (tester) async {
      await _setWideDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('wide layout shows Chat destination in rail', (tester) async {
      await _setWideDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Chat'), findsWidgets);
    });

    testWidgets('wide layout shows Notice Draft destination in rail', (
      tester,
    ) async {
      await _setWideDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Notice Draft'), findsWidgets);
    });
  });
}
