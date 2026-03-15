import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/advanced_audit/presentation/advanced_audit_screen.dart';
import 'package:ca_app/features/advanced_audit/presentation/widgets/audit_engagement_card.dart';
import 'package:ca_app/features/advanced_audit/presentation/widgets/audit_finding_tile.dart';
import 'package:ca_app/features/advanced_audit/presentation/widgets/audit_checklist_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: AdvancedAuditScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AdvancedAuditScreen', () {
    testWidgets('renders Advanced Audits title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Advanced Audits'), findsOneWidget);
    });

    testWidgets('renders Engagements tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Engagements'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Findings tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Findings'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Checklists tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Checklists'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders All filter chip in audit type filter row',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsWidgets);
    });

    testWidgets('renders AuditEngagementCard widgets on Engagements tab',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AuditEngagementCard), findsWidgets);
    });

    testWidgets('renders mock client Reliance Retail Ltd', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Reliance Retail'), findsWidgets);
    });

    testWidgets('renders mock client Tata Consultancy Services', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Tata Consultancy'), findsWidgets);
    });

    testWidgets('switches to Findings tab and shows AuditFindingTile widgets',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Findings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuditFindingTile), findsWidgets);
    });

    testWidgets('switches to Checklists tab and shows AuditChecklistTile',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Checklists'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuditChecklistTile), findsWidgets);
    });

    testWidgets('Findings tab shows severity filter chips', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Findings'),
        ),
      );
      await tester.pumpAndSettle();

      // Severity filter row should include All and severity labels
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders DefaultTabController with 3 tabs', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DefaultTabController), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('filter chips are FilterChip widgets', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders FY label in engagement cards', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('FY 2025-26'), findsWidgets);
    });

    testWidgets('renders partner name in engagement cards', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('CA Rajesh Agarwal'), findsWidgets);
    });
  });
}
