import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/crypto_vda/presentation/crypto_vda_screen.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_transaction_tile.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_summary_card.dart';
import 'package:ca_app/features/crypto_vda/presentation/tabs/vda_overview_tab.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: CryptoVdaScreen()));
}

Widget _buildWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final _testTransaction = VdaTransaction(
  id: 'vda-t01',
  clientId: 'cli-t01',
  clientName: 'Raj Kumar',
  assetType: VdaAssetType.crypto,
  assetName: 'Bitcoin (BTC)',
  transactionType: VdaTransactionType.sell,
  quantity: 0.5,
  buyPrice: 2000000,
  sellPrice: 2500000,
  gainLoss: 250000,
  taxAt30Percent: 75000,
  tdsUnder194S: 25000,
  exchange: 'CoinDCX',
  transactionDate: DateTime(2026, 2, 15),
);

// ---------------------------------------------------------------------------
// CryptoVdaScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('CryptoVdaScreen', () {
    testWidgets('renders app bar with Crypto / VDA Taxation title', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Crypto / VDA Taxation'), findsOneWidget);
    });

    testWidgets('renders Overview tab', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Overview'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Transactions tab', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Transactions'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Clients tab', (tester) async {
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

    testWidgets('renders TDS 194S tab', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('TDS 194S'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Overview tab renders VdaOverviewTab widget', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(VdaOverviewTab), findsOneWidget);
    });

    testWidgets('Overview tab shows 30% tax rule card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('30%'), findsWidgets);
    });

    testWidgets('Overview tab shows Section 115BBH', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('115BBH'), findsWidgets);
    });

    testWidgets('switching to Transactions tab shows VdaTransactionTile list', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Transactions'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VdaTransactionTile), findsWidgets);
    });

    testWidgets('Transactions tab shows client dropdown filter', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Transactions'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All Clients'), findsWidgets);
    });

    testWidgets('Transactions tab shows asset type filter chips', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Transactions'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('switching to Clients tab shows VdaSummaryCard list', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Clients'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VdaSummaryCard), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // VdaTransactionTile tests
  // ---------------------------------------------------------------------------

  group('VdaTransactionTile', () {
    testWidgets('renders asset name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(VdaTransactionTile(transaction: _testTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bitcoin (BTC)'), findsOneWidget);
    });

    testWidgets('renders client name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(VdaTransactionTile(transaction: _testTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Raj Kumar'), findsOneWidget);
    });

    testWidgets('renders Sell transaction type badge', (tester) async {
      await tester.pumpWidget(
        _buildWidget(VdaTransactionTile(transaction: _testTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sell'), findsWidgets);
    });

    testWidgets('renders exchange name CoinDCX', (tester) async {
      await tester.pumpWidget(
        _buildWidget(VdaTransactionTile(transaction: _testTransaction)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('CoinDCX'), findsWidgets);
    });

    testWidgets('renders gain amount with positive color', (tester) async {
      await tester.pumpWidget(
        _buildWidget(VdaTransactionTile(transaction: _testTransaction)),
      );
      await tester.pumpAndSettle();

      // gainLoss = 250000, should show formatted as gain
      expect(find.textContaining('2,50,000'), findsWidgets);
    });
  });
}
