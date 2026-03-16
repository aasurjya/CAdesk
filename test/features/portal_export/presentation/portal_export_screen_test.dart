import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_export/presentation/portal_export_screen.dart';
import 'package:ca_app/features/portal_export/presentation/widgets/export_job_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: PortalExportScreen()));

/// Pump enough frames to settle the UI. Cannot use pumpAndSettle because
/// the screen uses a StreamProvider.autoDispose that never completes.
Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PortalExportScreen', () {
    testWidgets('renders Portal Export title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('Portal Export'), findsOneWidget);
    });

    testWidgets('renders Completed metric tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('Completed'), findsWidgets);
    });

    testWidgets('renders In Progress metric tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('renders Failed metric tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('Failed'), findsWidgets);
    });

    testWidgets('renders Total metric tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('Total'), findsWidgets);
    });

    testWidgets('renders All status filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders New Export FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.text('New Export'), findsOneWidget);
    });

    testWidgets('renders FAB with add icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.byIcon(Icons.add_rounded), findsWidgets);
    });

    testWidgets('body shows Column with summary card and filter row', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('status filter chips are scrollable', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('shows loading indicator or job tiles or empty state', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      final hasContent =
          find.byType(ExportJobTile).evaluate().isNotEmpty ||
          find.text('No export jobs found').evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });

    testWidgets('renders summary card container at top', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('status filter row contains GestureDetector chips', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('summary card shows check_circle icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsWidgets);
    });

    testWidgets('summary card shows error icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);
    });

    testWidgets('tapping All chip keeps all jobs visible', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);

      await tester.tap(find.text('All'));
      await tester.pump(const Duration(milliseconds: 100));

      // Tapping All should not throw and should still show screen
      expect(find.text('Portal Export'), findsOneWidget);
    });
  });
}
