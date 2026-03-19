import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/cma/presentation/cma_screen.dart';
import 'package:ca_app/features/cma/presentation/widgets/cma_report_tile.dart';
import 'package:ca_app/features/cma/presentation/widgets/loan_summary_card.dart';
import 'package:ca_app/features/cma/domain/models/cma_report.dart';
import 'package:ca_app/features/cma/domain/models/loan_calculator.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: CmaScreen()));
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _testReport = CmaReport(
  id: 'cma-001',
  clientId: 'cli-001',
  clientName: 'Mehta Textiles Pvt Ltd',
  bankName: 'State Bank of India',
  loanPurpose: 'Working Capital',
  projectionYears: 3,
  status: CmaReportStatus.submitted,
  preparedDate: DateTime(2025, 8, 10),
  requestedAmount: 50000000,
  projections: [
    const YearProjection(
      year: 2025,
      sales: 45000000,
      cogs: 32000000,
      grossProfit: 13000000,
      operatingExpenses: 6000000,
      ebitda: 7000000,
      netProfit: 4500000,
      currentAssets: 18000000,
      currentLiabilities: 9000000,
      totalDebt: 12000000,
      netWorth: 8000000,
      dscr: 1.45,
      mpbf: 9000000,
    ),
  ],
);

final _testLoan = LoanCalculator(
  id: 'loan-001',
  clientId: 'cli-001',
  clientName: 'Mehta Textiles Pvt Ltd',
  loanAmount: 10000000,
  interestRate: 10.5,
  tenureMonths: 60,
  emi: 215000,
  totalInterest: 2900000,
  totalPayment: 12900000,
  disbursementDate: DateTime(2024, 1, 1),
  amortizationSchedule: const [],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CmaScreen', () {
    testWidgets('renders app bar with CMA / Financial Projections title', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('CMA / Financial Projections'), findsOneWidget);
    });

    testWidgets('renders CMA Reports tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('CMA Reports'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Loan Calculator tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Loan Calculator'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Calculator Tools tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Calculator Tools'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders summary strip with Reports label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('renders summary strip with Pending label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('renders New CMA FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New CMA'), findsOneWidget);
    });

    testWidgets('renders CMA report tiles in CMA Reports tab', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CmaReportTile), findsWidgets);
    });

    testWidgets('filter chips are shown in CMA Reports tab', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // "All" filter chip plus status filter chips
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('switching to Loan Calculator tab shows loan cards', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Loan Calculator'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoanSummaryCard), findsWidgets);
    });

    testWidgets('switching to Calculator Tools tab shows tool tiles', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Calculator Tools'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EMI / Loan Calculator'), findsOneWidget);
      expect(find.text('NPV / IRR Analysis'), findsOneWidget);
    });
  });

  group('CmaReportTile', () {
    testWidgets('renders client name', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CmaReportTile(report: _testReport)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mehta Textiles'), findsOneWidget);
    });

    testWidgets('renders bank name', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CmaReportTile(report: _testReport)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('State Bank'), findsOneWidget);
    });

    testWidgets('renders status badge', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CmaReportTile(report: _testReport)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Submitted'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      await _setDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CmaReportTile(
              report: _testReport,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CmaReportTile));
      expect(tapped, isTrue);
    });
  });

  group('LoanSummaryCard', () {
    testWidgets('renders client name', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LoanSummaryCard(loan: _testLoan)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mehta Textiles'), findsOneWidget);
    });

    testWidgets('renders interest rate', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LoanSummaryCard(loan: _testLoan)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('10.5'), findsOneWidget);
    });

    testWidgets('renders EMI label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LoanSummaryCard(loan: _testLoan)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('EMI'), findsWidgets);
    });

    testWidgets('renders tenure progress bar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LoanSummaryCard(loan: _testLoan)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
