import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/llp_compliance/presentation/llp_compliance_screen.dart';
import 'package:ca_app/features/llp_compliance/presentation/widgets/llp_entity_card.dart';
import 'package:ca_app/features/llp_compliance/presentation/widgets/llp_filing_tile.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_entity.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: LLPComplianceScreen()),
  );
}

Widget _buildWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final _testEntity = LLPEntity(
  id: 'llp-t01',
  llpName: 'Test Partners LLP',
  llpin: 'AAZ-0001',
  incorporationDate: DateTime(2020, 6, 1),
  turnover: 5000000,
  capitalContribution: 2000000,
  isAuditRequired: false,
  designatedPartners: const [
    LLPPartner(
      name: 'Alice Sharma',
      din: '09000001',
      email: 'alice@testllp.in',
      isDesignated: true,
    ),
    LLPPartner(
      name: 'Bob Kumar',
      din: '09000002',
      email: 'bob@testllp.in',
      isDesignated: true,
    ),
  ],
  registeredOffice: '1, MG Road, Bengaluru 560001',
  rocJurisdiction: 'ROC Karnataka',
);

final _testFiling = LLPFiling(
  id: 'llpf-t01',
  llpId: 'llp-t01',
  llpName: 'Test Partners LLP',
  formType: LLPFormType.form11,
  dueDate: DateTime(2026, 5, 30),
  status: LLPFilingStatus.pending,
  financialYear: '2025-26',
  penaltyPerDay: 100,
  maxPenalty: 100000,
  currentPenalty: 0,
);

// ---------------------------------------------------------------------------
// LLPComplianceScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('LLPComplianceScreen', () {
    testWidgets('renders app bar with LLP Compliance title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('LLP Compliance'), findsOneWidget);
    });

    testWidgets('renders LLPs, Filings, and Penalties tabs', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('LLPs')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Penalties'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('LLPs tab shows summary bar with LLPs metric', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('LLPs'), findsWidgets);
    });

    testWidgets('LLPs tab shows Audit Req. metric', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Audit'), findsWidgets);
    });

    testWidgets('LLPs tab shows LLPEntityCard list', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(LLPEntityCard), findsWidgets);
    });

    testWidgets('switching to Filings tab shows LLPFilingTile list',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LLPFilingTile), findsWidgets);
    });

    testWidgets('Filings tab shows All LLPs dropdown', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All LLPs'), findsWidgets);
    });

    testWidgets('Filings tab shows form type filter chips', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('switching to Penalties tab shows Total Penalty Exposure',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Penalties'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Penalty Exposure'), findsOneWidget);
    });

    testWidgets('LLPs tab shows Sharma & Gupta Associates from mock data',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Sharma'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // LLPEntityCard tests
  // ---------------------------------------------------------------------------

  group('LLPEntityCard', () {
    testWidgets('renders LLP name', (tester) async {
      await tester.pumpWidget(_buildWidget(LLPEntityCard(entity: _testEntity)));
      await tester.pumpAndSettle();

      expect(find.text('Test Partners LLP'), findsOneWidget);
    });

    testWidgets('renders LLPIN badge', (tester) async {
      await tester.pumpWidget(_buildWidget(LLPEntityCard(entity: _testEntity)));
      await tester.pumpAndSettle();

      expect(find.textContaining('AAZ-0001'), findsWidgets);
    });

    testWidgets('renders ROC jurisdiction', (tester) async {
      await tester.pumpWidget(_buildWidget(LLPEntityCard(entity: _testEntity)));
      await tester.pumpAndSettle();

      expect(find.textContaining('ROC Karnataka'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // LLPFilingTile tests
  // ---------------------------------------------------------------------------

  group('LLPFilingTile', () {
    testWidgets('renders LLP name', (tester) async {
      await tester.pumpWidget(_buildWidget(LLPFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Test Partners LLP'), findsWidgets);
    });

    testWidgets('renders Form 11 type badge', (tester) async {
      await tester.pumpWidget(_buildWidget(LLPFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Form 11'), findsWidgets);
    });

    testWidgets('renders Pending status badge', (tester) async {
      await tester.pumpWidget(_buildWidget(LLPFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders financial year', (tester) async {
      await tester.pumpWidget(_buildWidget(LLPFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('2025-26'), findsWidgets);
    });
  });
}
