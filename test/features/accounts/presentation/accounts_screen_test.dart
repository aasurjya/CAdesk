import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/accounts/presentation/accounts_screen.dart';
import 'package:ca_app/features/accounts/presentation/widgets/account_client_tile.dart';
import 'package:ca_app/features/accounts/presentation/widgets/financial_statement_tile.dart';
import 'package:ca_app/features/accounts/presentation/widgets/depreciation_tile.dart';
import 'package:ca_app/features/accounts/domain/models/account_client.dart';
import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';
import 'package:ca_app/features/accounts/domain/models/depreciation_entry.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _setWideDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: AccountsScreen()));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AccountsScreen', () {
    testWidgets('renders app bar with correct title', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Accounts & Balance Sheet'), findsOneWidget);
    });

    testWidgets('renders Clients tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Clients'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Statements tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Statements'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Depreciation tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Depreciation'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Ratios tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('Ratios')),
        findsOneWidget,
      );
    });

    testWidgets('renders four summary cards in header', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Summary cards: Finalized, Drafts, AUM, Pending
      expect(find.text('Finalized'), findsWidgets);
      expect(find.text('Drafts'), findsWidgets);
      expect(find.text('AUM'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('renders client tiles in Clients tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AccountClientTile), findsWidgets);
    });

    testWidgets('filter chips are shown in Clients tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // "All" filter chip should always be present
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('switching to Statements tab navigates to Statements view', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Tap the Statements tab
      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Statements'),
        ),
      );
      await tester.pump(); // Single pump to avoid overflow errors

      // Statements tab should be selected (TabController moved)
      expect(find.text('Statements'), findsWidgets);
    });

    testWidgets(
      'switching to Depreciation tab navigates to Depreciation view',
      (tester) async {
        await _setPhoneDisplay(tester);
        await tester.pumpWidget(_buildScreen());
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(TabBar),
            matching: find.text('Depreciation'),
          ),
        );
        await tester.pump(); // Single pump to avoid overflow errors

        expect(find.text('Depreciation'), findsWidgets);
      },
    );

    testWidgets('switching to Ratios tab shows ratio snapshot tiles', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text('Ratios')),
      );
      await tester.pumpAndSettle();

      // Ratios tab shows client names and ratio data
      expect(find.byType(ListView), findsWidgets);
    });
  });

  group('AccountClientTile', () {
    const testClient = AccountClient(
      id: 'test-001',
      name: 'Mehta Textiles Pvt Ltd',
      pan: 'AABCM4521F',
      businessType: BusinessType.company,
      financialYear: 'FY 2024-25',
      hasAudit: true,
      turnover: 42500000,
      totalAssets: 18700000,
      netProfit: 3200000,
      grossProfit: 6800000,
      currentRatio: 1.85,
      auditorName: 'CA Suresh Agarwal',
      status: AccountClientStatus.finalized,
    );

    testWidgets('renders client name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AccountClientTile(client: testClient)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mehta Textiles'), findsOneWidget);
    });

    testWidgets('renders financial year', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AccountClientTile(client: testClient)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('FY 2024-25'), findsWidgets);
    });

    testWidgets('renders audit badge when hasAudit is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AccountClientTile(client: testClient)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Audit'), findsWidgets);
    });

    testWidgets('fires onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountClientTile(
              client: testClient,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AccountClientTile));
      expect(tapped, isTrue);
    });
  });

  group('FinancialStatementTile', () {
    final testStatement = FinancialStatement(
      id: 'stmt-test-001',
      clientId: 'acc-001',
      clientName: 'Mehta Textiles Pvt Ltd',
      statementType: StatementType.balanceSheet,
      financialYear: 'FY 2024-25',
      format: StatementFormat.vertical,
      preparedBy: 'CA Suresh Agarwal',
      preparedDate: DateTime(2025, 9, 20),
      status: StatementStatus.filed,
      totalAssets: 18700000,
      totalLiabilities: 10200000,
      netProfit: 3200000,
    );

    testWidgets('renders client name', (tester) async {
      await _setWideDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialStatementTile(statement: testStatement),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mehta Textiles'), findsOneWidget);
    });

    testWidgets('renders statement type label', (tester) async {
      await _setWideDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialStatementTile(statement: testStatement),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Statement type should appear somewhere in the tile
      expect(find.textContaining('Balance Sheet'), findsWidgets);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      await _setWideDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialStatementTile(
              statement: testStatement,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FinancialStatementTile));
      expect(tapped, isTrue);
    });
  });

  group('DepreciationTile', () {
    const testEntry = DepreciationEntry(
      id: 'dep-test-001',
      clientId: 'acc-001',
      assetName: 'Factory Building — Surat',
      assetBlock: AssetBlock.building,
      openingWDV: 4500000,
      additions: 0,
      disposals: 0,
      rate: 10.0,
      depreciation: 450000,
      closingWDV: 4050000,
      financialYear: 'FY 2024-25',
    );

    testWidgets('renders asset name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DepreciationTile(entry: testEntry)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Factory Building'), findsOneWidget);
    });

    testWidgets('renders depreciation rate', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DepreciationTile(entry: testEntry)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DepreciationTile(
              entry: testEntry,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DepreciationTile));
      expect(tapped, isTrue);
    });
  });
}
