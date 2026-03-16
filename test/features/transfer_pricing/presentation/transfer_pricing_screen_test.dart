import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/transfer_pricing/presentation/transfer_pricing_screen.dart';
import 'package:ca_app/features/transfer_pricing/presentation/widgets/tp_study_tile.dart';
import 'package:ca_app/features/transfer_pricing/presentation/widgets/tp_filing_tile.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_study.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_filing.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: TransferPricingScreen()));
}

Widget _buildWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final _testStudy = TpStudy(
  id: 'tp-t01',
  clientId: 'cl-t01',
  clientName: 'Global Tech Ltd',
  financialYear: '2025-26',
  studyType: TpStudyType.localFile,
  status: TpStudyStatus.analysis,
  analystName: 'CA Test Analyst',
  dueDate: DateTime(2026, 11, 30),
  transactionValue: 2000000000,
  method: TpMethod.tnmm,
);

final _testFiling = TpFiling(
  id: 'tpf-t01',
  clientId: 'cl-t01',
  clientName: 'Global Tech Ltd',
  assessmentYear: '2026-27',
  certifyingCA: 'CA Test CA, FRN 099999S',
  dueDate: DateTime(2026, 10, 31),
  status: TpFilingStatus.underPreparation,
  internationalTransactions: const [
    TpTransaction(
      description: 'Software services to Global Tech USA',
      method: 'TNMM',
      alpValue: 1500000000,
      actualValue: 1480000000,
      adjustment: 20000000,
    ),
  ],
);

// ---------------------------------------------------------------------------
// TransferPricingScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('TransferPricingScreen', () {
    testWidgets('renders app bar with Transfer Pricing title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Transfer Pricing'), findsOneWidget);
    });

    testWidgets('renders TP Studies and Form 3CEB tabs', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('TP Studies'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Form 3CEB'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Total Studies summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total Studies'), findsOneWidget);
    });

    testWidgets('renders In Progress summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('renders Completed summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('renders 3CEB Pending summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('3CEB Pending'), findsOneWidget);
    });

    testWidgets('TP Studies tab shows TpStudyTile list', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TpStudyTile), findsWidgets);
    });

    testWidgets('status filter chips are present', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('switching to Form 3CEB tab shows TpFilingTile list', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Form 3CEB'));
      await tester.pumpAndSettle();

      expect(find.byType(TpFilingTile), findsWidgets);
    });

    testWidgets('Form 3CEB tab shows filing status filter chips', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Form 3CEB'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('TP Studies tab shows TCS study', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Tata Consultancy'), findsWidgets);
    });

    testWidgets('summary cards show counts from mock data', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // 6 total studies
      expect(find.text('6'), findsWidgets);
    });

    testWidgets('TNMM filter chip is shown for studies', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Chip labels like Analysis, Final etc. should appear
      expect(find.byType(FilterChip), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // TpStudyTile tests
  // ---------------------------------------------------------------------------

  group('TpStudyTile', () {
    testWidgets('renders client name', (tester) async {
      await tester.pumpWidget(_buildWidget(TpStudyTile(study: _testStudy)));
      await tester.pumpAndSettle();

      expect(find.text('Global Tech Ltd'), findsOneWidget);
    });

    testWidgets('renders study type badge', (tester) async {
      await tester.pumpWidget(_buildWidget(TpStudyTile(study: _testStudy)));
      await tester.pumpAndSettle();

      expect(find.text('Local File'), findsOneWidget);
    });

    testWidgets('renders TP method badge TNMM', (tester) async {
      await tester.pumpWidget(_buildWidget(TpStudyTile(study: _testStudy)));
      await tester.pumpAndSettle();

      expect(find.text('TNMM'), findsOneWidget);
    });

    testWidgets('renders financial year', (tester) async {
      await tester.pumpWidget(_buildWidget(TpStudyTile(study: _testStudy)));
      await tester.pumpAndSettle();

      expect(find.textContaining('2025-26'), findsWidgets);
    });

    testWidgets('renders analyst name', (tester) async {
      await tester.pumpWidget(_buildWidget(TpStudyTile(study: _testStudy)));
      await tester.pumpAndSettle();

      expect(find.text('CA Test Analyst'), findsOneWidget);
    });

    testWidgets('renders due date', (tester) async {
      await tester.pumpWidget(_buildWidget(TpStudyTile(study: _testStudy)));
      await tester.pumpAndSettle();

      expect(find.textContaining('30 Nov 2026'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // TpFilingTile tests
  // ---------------------------------------------------------------------------

  group('TpFilingTile', () {
    testWidgets('renders client name', (tester) async {
      await tester.pumpWidget(_buildWidget(TpFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.text('Global Tech Ltd'), findsOneWidget);
    });

    testWidgets('renders assessment year', (tester) async {
      await tester.pumpWidget(_buildWidget(TpFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('2026-27'), findsWidgets);
    });

    testWidgets('renders certifying CA', (tester) async {
      await tester.pumpWidget(_buildWidget(TpFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('CA Test CA'), findsWidgets);
    });

    testWidgets('renders Under Preparation status', (tester) async {
      await tester.pumpWidget(_buildWidget(TpFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Under Preparation'), findsWidgets);
    });
  });
}
