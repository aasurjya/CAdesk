import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/fema/presentation/fema_screen.dart';
import 'package:ca_app/features/fema/presentation/widgets/fema_filing_tile.dart';
import 'package:ca_app/features/fema/presentation/widgets/fdi_transaction_tile.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing.dart';
import 'package:ca_app/features/fema/domain/models/fdi_transaction.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: FemaScreen()),
  );
}

Widget _buildWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final _testFiling = FemaFiling(
  id: 'fema-t01',
  clientId: 'cl-t01',
  clientName: 'Test Corp Ltd',
  formType: FemaFormType.fcGpr,
  filingDate: DateTime(2026, 2, 1),
  dueDate: DateTime(2026, 3, 31),
  status: FemaFilingStatus.submitted,
  amount: 1000000,
  currency: 'USD',
  referenceNumber: 'FCG/2026/TEST/001',
  adBankName: 'State Bank of India',
);

final _testFdiTransaction = FdiTransaction(
  id: 'fdi-t01',
  clientId: 'cl-t01',
  entityName: 'Test Tech Pvt Ltd',
  investorName: 'Acme Capital Fund',
  investorCountry: 'United States',
  amount: 5000000,
  currency: 'USD',
  equityPercentage: 12.5,
  sectorCap: 100.0,
  approvalRoute: FdiApprovalRoute.automatic,
  transactionDate: DateTime(2026, 2, 10),
  status: FdiTransactionStatus.approved,
);

// ---------------------------------------------------------------------------
// FemaScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('FemaScreen', () {
    testWidgets('renders app bar with FEMA title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('FEMA & RBI Compliance'), findsOneWidget);
    });

    testWidgets('renders Filings and FDI Tracker tabs', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('Filings')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('FDI Tracker'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Total Filings summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total Filings'), findsOneWidget);
    });

    testWidgets('renders Pending summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders Overdue summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('renders Active FDI summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Active FDI'), findsOneWidget);
    });

    testWidgets('Filings tab shows FemaFilingTile list', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FemaFilingTile), findsWidgets);
    });

    testWidgets('status filter chips are shown in Filings tab', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('tapping FDI Tracker tab shows FdiTransactionTile list',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('FDI Tracker'));
      await tester.pumpAndSettle();

      expect(find.byType(FdiTransactionTile), findsWidgets);
    });

    testWidgets('FDI Tracker tab shows status filter chips', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('FDI Tracker'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('summary cards show non-zero counts from mock data',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Mock data has 6 filings; at least one count widget must be non-zero
      expect(find.text('6'), findsWidgets);
    });

    testWidgets('Filings tab shows Wipro Technologies filing', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Wipro'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // FemaFilingTile tests
  // ---------------------------------------------------------------------------

  group('FemaFilingTile', () {
    testWidgets('renders client name', (tester) async {
      await tester.pumpWidget(_buildWidget(FemaFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.text('Test Corp Ltd'), findsOneWidget);
    });

    testWidgets('renders FC-GPR form type badge', (tester) async {
      await tester.pumpWidget(_buildWidget(FemaFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.text('FC-GPR'), findsOneWidget);
    });

    testWidgets('renders Submitted status badge', (tester) async {
      await tester.pumpWidget(_buildWidget(FemaFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.text('Submitted'), findsOneWidget);
    });

    testWidgets('renders due date', (tester) async {
      await tester.pumpWidget(_buildWidget(FemaFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('31 Mar 2026'), findsOneWidget);
    });

    testWidgets('renders reference number when present', (tester) async {
      await tester.pumpWidget(_buildWidget(FemaFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('FCG/2026/TEST/001'), findsOneWidget);
    });

    testWidgets('renders AD bank name', (tester) async {
      await tester.pumpWidget(_buildWidget(FemaFilingTile(filing: _testFiling)));
      await tester.pumpAndSettle();

      expect(find.textContaining('State Bank of India'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // FdiTransactionTile tests
  // ---------------------------------------------------------------------------

  group('FdiTransactionTile', () {
    testWidgets('renders entity name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(FdiTransactionTile(transaction: _testFdiTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Tech Pvt Ltd'), findsOneWidget);
    });

    testWidgets('renders investor name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(FdiTransactionTile(transaction: _testFdiTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Acme Capital Fund'), findsWidgets);
    });

    testWidgets('renders Approved status', (tester) async {
      await tester.pumpWidget(
        _buildWidget(FdiTransactionTile(transaction: _testFdiTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('renders investor country', (tester) async {
      await tester.pumpWidget(
        _buildWidget(FdiTransactionTile(transaction: _testFdiTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('United States'), findsWidgets);
    });

    testWidgets('renders approval route Automatic', (tester) async {
      await tester.pumpWidget(
        _buildWidget(FdiTransactionTile(transaction: _testFdiTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Automatic'), findsWidgets);
    });
  });
}
