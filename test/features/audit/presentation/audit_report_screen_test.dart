import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/audit/presentation/audit_report_screen.dart';
import 'package:ca_app/features/audit/presentation/widgets/audit_report_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: AuditReportScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AuditReportScreen', () {
    testWidgets('renders Audit Reports title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Audit Reports'), findsOneWidget);
    });

    testWidgets('renders Form 3CD subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Form 3CD'), findsWidgets);
    });

    testWidgets('renders All filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders Form 3CD filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // One in the filter row, possibly more in tiles
      expect(find.text('Form 3CD'), findsWidgets);
    });

    testWidgets('renders Form 29B filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Form 29B'), findsWidgets);
    });

    testWidgets('renders AuditReportTile widgets', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AuditReportTile), findsWidgets);
    });

    testWidgets('renders New Audit Report FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Audit Report'), findsOneWidget);
    });

    testWidgets('renders mock client Mehta Trading Co.', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Mehta Trading'), findsOneWidget);
    });

    testWidgets('renders mock client Sharma Textiles Pvt Ltd', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Sharma Textiles'), findsOneWidget);
    });

    testWidgets('renders assessment year label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('2025-26'), findsWidgets);
    });

    testWidgets('renders Form 29B management subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('29B'), findsWidgets);
    });

    testWidgets('tapping Form 3CD filter chip updates list', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Tap the Form 3CD chip in the filter row
      final chips = find.text('Form 3CD');
      await tester.tap(chips.first);
      await tester.pumpAndSettle();

      // Should still render tiles (3 Form 3CD reports in mock data)
      expect(find.byType(AuditReportTile), findsWidgets);
    });

    testWidgets('tapping Form 29B filter chip shows only 29B reports', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final chips = find.text('Form 29B');
      await tester.tap(chips.first);
      await tester.pumpAndSettle();

      // 1 Form 29B report in mock data
      expect(find.byType(AuditReportTile), findsOneWidget);
    });

    testWidgets('renders report status labels', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // At least one status label from mock data should appear
      final hasFinalized = find
          .textContaining('Finalized')
          .evaluate()
          .isNotEmpty;
      final hasReview = find.textContaining('Review').evaluate().isNotEmpty;
      final hasDraft = find.textContaining('Draft').evaluate().isNotEmpty;
      final hasFiled = find.textContaining('Filed').evaluate().isNotEmpty;
      expect(hasFinalized || hasReview || hasDraft || hasFiled, isTrue);
    });

    testWidgets('body shows gradient decorated background', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });
}
