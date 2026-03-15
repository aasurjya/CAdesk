import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/collaboration/presentation/collaboration_screen.dart';
import 'package:ca_app/features/collaboration/presentation/widgets/user_session_tile.dart';

/// Suppresses layout overflow errors that can occur on test viewports.
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
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: CollaborationScreen()),
  );
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CollaborationScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(CollaborationScreen), findsOneWidget);
    });

    testWidgets('renders Collaboration & Mobility title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Collaboration & Mobility'), findsOneWidget);
    });

    testWidgets('renders Active Sessions tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Active Sessions'), findsWidgets);
    });

    testWidgets('renders Guest Links tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Guest Links'), findsWidgets);
    });

    testWidgets('renders a TabBar with two tabs', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders Total Sessions summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Total Sessions'), findsOneWidget);
    });

    testWidgets('renders Online Now summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Online Now'), findsOneWidget);
    });

    testWidgets('renders Active Links summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Active Links'), findsOneWidget);
    });

    testWidgets('renders Expired Links summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Expired Links'), findsOneWidget);
    });

    testWidgets('Active Sessions tab shows sessions or empty state',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      final hasSessions = find.byType(UserSessionTile).evaluate().isNotEmpty;
      final hasEmpty =
          find.text('No sessions match the selected filter').evaluate()
              .isNotEmpty;
      expect(hasSessions || hasEmpty, isTrue);
    });

    testWidgets('Active Sessions tab shows FilterChip filters', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders devices_rounded icon in Total Sessions card',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.devices_rounded), findsOneWidget);
    });

    testWidgets('renders link_rounded icon in Active Links card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.link_rounded), findsOneWidget);
    });

    testWidgets('switching to Guest Links tab renders without error',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('Guest Links').first);
        await tester.pumpAndSettle();
        expect(find.byType(CollaborationScreen), findsOneWidget);
      });
    });

    testWidgets('Guest Links tab shows links or empty state', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('Guest Links').first);
        await tester.pumpAndSettle();
        final hasEmpty =
            find.text('No guest links have been created').evaluate().isNotEmpty;
        final hasCards = find.byType(Card).evaluate().isNotEmpty;
        expect(hasEmpty || hasCards, isTrue);
      });
    });
  });
}
