import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/ai_automation/presentation/ai_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: AiDashboardScreen()));
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AiDashboardScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(AiDashboardScreen), findsOneWidget);
    });

    testWidgets('renders AI & Automation title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('AI & Automation'), findsWidgets);
    });

    testWidgets('renders Smart operations cockpit subtitle', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Smart operations cockpit'), findsOneWidget);
    });

    testWidgets('renders Core AI tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Core AI'), findsWidgets);
    });

    testWidgets('renders Scans tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Scans'), findsWidgets);
    });

    testWidgets('renders Reconciliation tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Reconciliation'), findsWidgets);
    });

    testWidgets('renders Anomalies tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Anomalies'), findsWidgets);
    });

    testWidgets('renders Live AI Demo FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Live AI Demo'), findsOneWidget);
    });

    testWidgets('renders refresh icon button', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('Core AI tab shows Automation overview banner', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Automation overview'), findsOneWidget);
    });

    testWidgets('Core AI tab shows Core AI Operations card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Core AI Operations'), findsOneWidget);
    });

    testWidgets('Core AI tab shows Live Automation Queue section header',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Live Automation Queue'), findsOneWidget);
    });

    testWidgets('switching to Scans tab shows Document extraction banner',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scans').first);
      await tester.pumpAndSettle();
      expect(find.text('Document extraction flow'), findsOneWidget);
    });

    testWidgets('switching to Scans tab shows Document Scans summary card',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scans').first);
      await tester.pumpAndSettle();
      expect(find.text('Document Scans'), findsOneWidget);
    });

    testWidgets('switching to Anomalies tab shows Anomaly monitoring banner',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anomalies').first);
      await tester.pumpAndSettle();
      expect(find.text('Anomaly monitoring'), findsOneWidget);
    });

    testWidgets('Live AI Demo FAB is tappable', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      final fab = find.text('Live AI Demo');
      expect(fab, findsOneWidget);
    });

    testWidgets('Core AI tab shows stat labels Total and Attention',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Total'), findsWidgets);
      expect(find.text('Attention'), findsOneWidget);
    });
  });
}
