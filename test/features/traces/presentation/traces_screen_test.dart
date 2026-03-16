import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/traces/presentation/traces_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: TracesScreen()));

void main() {
  group('TracesScreen', () {
    testWidgets('renders TRACES Portal title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('TRACES Portal'), findsOneWidget);
    });

    testWidgets('renders TDS certificates challans defaults subtitle', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('TDS certificates'), findsOneWidget);
    });

    testWidgets('renders Bulk Download action button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Bulk Download'), findsOneWidget);
    });

    testWidgets('renders download icon in Bulk Download button', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('renders Requests stat label in summary banner', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('renders Unverified stat label in summary banner', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Unverified'), findsOneWidget);
    });

    testWidgets('renders Demand stat label in summary banner', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Demand'), findsOneWidget);
    });

    testWidgets('renders Recent Requests section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recent Requests'), findsOneWidget);
    });

    testWidgets('renders history icon for Recent Requests', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('renders Challan Verification section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Challan Verification'), findsOneWidget);
    });

    testWidgets('renders verified icon for Challan Verification', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });

    testWidgets('renders TDS Defaults section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('TDS Defaults'), findsOneWidget);
    });

    testWidgets('renders warning icon for TDS Defaults', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders challan BSR info in Challan list', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(find.textContaining('BSR:'), findsWidgets);
    });

    testWidgets('renders TAN info in TDS Defaults list', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.textContaining('TAN:'), findsWidgets);
    });
  });
}
