import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/bulk_operations/presentation/bulk_dashboard_screen.dart';
import 'package:ca_app/features/bulk_operations/presentation/widgets/batch_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: BulkDashboardScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BulkDashboardScreen', () {
    testWidgets('renders Bulk Operations title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Bulk Operations'), findsOneWidget);
    });

    testWidgets('renders Batch filing queue subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Batch filing queue'), findsOneWidget);
    });

    testWidgets('renders Active Batches stat card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Active Batches'), findsOneWidget);
    });

    testWidgets('renders Total Jobs stat card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total Jobs'), findsOneWidget);
    });

    testWidgets('renders Success Rate stat card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Success Rate'), findsOneWidget);
    });

    testWidgets('renders Filing Batches section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filing Batches'), findsOneWidget);
    });

    testWidgets('renders BatchCard widgets for mock batches', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(BatchCard), findsWidgets);
    });

    testWidgets('renders 5 batch cards matching mock data count', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(BatchCard), findsNWidgets(5));
    });

    testWidgets('renders New Batch FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Batch'), findsOneWidget);
    });

    testWidgets('FAB has add icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsWidgets);
    });

    testWidgets('renders ITR Bulk batch name', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('ITR Bulk'), findsWidgets);
    });

    testWidgets('renders GST 3B batch name', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('GST 3B'), findsWidgets);
    });

    testWidgets('renders TDS Q3 Returns batch name', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('TDS Q3'), findsWidgets);
    });

    testWidgets('body uses gradient decorated background', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('body is a scrollable ListView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('stat cards render as Card widgets', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('success rate value contains percent sign', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('%'), findsWidgets);
    });
  });
}
