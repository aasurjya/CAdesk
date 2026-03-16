import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:ca_app/features/income_tax/presentation/income_tax_screen.dart';
import 'package:ca_app/features/income_tax/presentation/widgets/itr_client_tile.dart';
import 'package:ca_app/features/income_tax/presentation/widgets/itr_summary_card.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const _testClient = ItrClient(
  id: 'itr-test-001',
  name: 'Priya Nair',
  pan: 'ABCPN1234E',
  aadhaar: '1234 5678 9012',
  email: 'priya.nair@example.com',
  phone: '9876543210',
  itrType: ItrType.itr1,
  assessmentYear: 'AY 2026-27',
  filingStatus: FilingStatus.pending,
  totalIncome: 850000,
  taxPayable: 42500,
  refundDue: 0,
);

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: IncomeTaxScreen()));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('IncomeTaxScreen', () {
    testWidgets('renders app bar with Income Tax title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Income Tax'), findsOneWidget);
    });

    testWidgets('renders search icon in app bar', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('tapping search icon shows text field', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders four ItrSummaryCards', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ItrSummaryCard), findsNWidgets(4));
    });

    testWidgets('summary cards show Total, Filed, Pending, Overdue labels', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Filed'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('renders assessment year dropdown', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('AY 2026-27'), findsOneWidget);
    });

    testWidgets('renders ITR type filter chips: All, ITR-1, ITR-2, ITR-3', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('ITR-1'), findsWidgets);
      expect(find.text('ITR-2'), findsWidgets);
      expect(find.text('ITR-3'), findsWidgets);
    });

    testWidgets('renders ItrClientTile list', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ItrClientTile), findsWidgets);
    });

    testWidgets('renders New Filing FAB', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Filing'), findsOneWidget);
    });

    testWidgets('tapping New Filing FAB opens bottom sheet', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Filing'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('tapping search close icon restores title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      // Close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Income Tax'), findsOneWidget);
    });
  });

  group('ItrSummaryCard', () {
    testWidgets('renders label and count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ItrSummaryCard(
                  label: 'Filed',
                  count: 12,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Filed'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('renders trend badge when trend is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ItrSummaryCard(
                  label: 'Filed',
                  count: 12,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  trend: 3,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
      expect(find.textContaining('+3'), findsOneWidget);
    });

    testWidgets('no trend badge when trend is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ItrSummaryCard(
                  label: 'Pending',
                  count: 5,
                  icon: Icons.hourglass_empty_rounded,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up_rounded), findsNothing);
      expect(find.byIcon(Icons.trending_down_rounded), findsNothing);
    });
  });

  group('ItrClientTile', () {
    testWidgets('renders client name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ItrClientTile(client: _testClient)),
        ),
      );

      expect(find.text('Priya Nair'), findsOneWidget);
    });

    testWidgets('renders masked PAN', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ItrClientTile(client: _testClient)),
        ),
      );

      // Masked PAN: XXXXX1234E
      expect(find.textContaining('XXXXX1234E'), findsOneWidget);
    });

    testWidgets('renders ITR type chip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ItrClientTile(client: _testClient)),
        ),
      );

      expect(find.text('ITR-1'), findsOneWidget);
    });

    testWidgets('renders filing status badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ItrClientTile(client: _testClient)),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders initials avatar correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ItrClientTile(client: _testClient)),
        ),
      );

      // Initials = PN
      expect(find.text('PN'), findsOneWidget);
    });

    testWidgets('renders filed date when available', (tester) async {
      final filedClient = ItrClient(
        id: 'itr-test-002',
        name: 'Arjun Mehta',
        pan: 'ABCAM5678F',
        aadhaar: '9876 5432 1098',
        email: 'arjun.mehta@example.com',
        phone: '9812345678',
        itrType: ItrType.itr2,
        assessmentYear: 'AY 2026-27',
        filingStatus: FilingStatus.filed,
        totalIncome: 1500000,
        taxPayable: 120000,
        refundDue: 0,
        filedDate: DateTime(2026, 3, 5),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ItrClientTile(client: filedClient)),
        ),
      );

      expect(find.textContaining('Filed:'), findsOneWidget);
      expect(find.textContaining('05 Mar 2026'), findsOneWidget);
    });

    testWidgets('tapping tile fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItrClientTile(
              client: _testClient,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ItrClientTile));
      expect(tapped, isTrue);
    });
  });
}
