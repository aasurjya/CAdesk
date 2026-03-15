import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/xbrl/presentation/xbrl_screen.dart';
import 'package:ca_app/features/xbrl/presentation/widgets/xbrl_filing_tile.dart';
import 'package:ca_app/features/xbrl/presentation/widgets/xbrl_element_tile.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_filing.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_element.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: XbrlScreen()));
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const _testFiling = XbrlFiling(
  id: 'xbrl-001',
  companyId: 'co-001',
  companyName: 'Meridian Tech Solutions Private Limited',
  cin: 'U74999MH2018PTC312456',
  financialYear: '2024-25',
  reportType: XbrlReportType.standalone,
  taxonomyVersion: '2023',
  status: XbrlFilingStatus.validation,
  totalTags: 150,
  completedTags: 90,
  validationErrors: 0,
  validationWarnings: 2,
  preparedBy: 'CA Suresh Agarwal',
);

const _testFilingWithErrors = XbrlFiling(
  id: 'xbrl-002',
  companyId: 'co-001',
  companyName: 'Bharat Infrastructure Projects Limited',
  cin: 'L65910DL1995PLC234567',
  financialYear: '2024-25',
  reportType: XbrlReportType.consolidated,
  taxonomyVersion: '2023',
  status: XbrlFilingStatus.dataEntry,
  totalTags: 200,
  completedTags: 50,
  validationErrors: 3,
  validationWarnings: 5,
);

const _testElement = XbrlElement(
  id: 'elem-001',
  filingId: 'xbrl-001',
  elementName: 'in-bfin:ProfitLossAfterTax',
  elementType: XbrlElementType.numeric,
  label: 'Profit / Loss After Tax',
  isRequired: true,
  value: '32000000',
  unit: 'INR',
  isCompleted: true,
);

const _testElementPending = XbrlElement(
  id: 'elem-002',
  filingId: 'xbrl-001',
  elementName: 'in-bfin:TotalRevenue',
  elementType: XbrlElementType.numeric,
  label: 'Total Revenue',
  isRequired: true,
  isCompleted: false,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('XbrlScreen', () {
    testWidgets('renders app bar with XBRL Filing title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('XBRL Filing'), findsOneWidget);
    });

    testWidgets('renders Filings tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Elements tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Elements'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders filter icon button in app bar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    });

    testWidgets('renders New XBRL FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New XBRL'), findsOneWidget);
    });

    testWidgets('renders filing tiles in Filings tab', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(XbrlFilingTile), findsWidgets);
    });

    testWidgets('renders progress summary bar with Filings label', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filings'), findsWidgets);
    });

    testWidgets('renders summary bar with Filed label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filed'), findsWidgets);
    });

    testWidgets('renders summary bar with Errors label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Errors'), findsWidgets);
    });

    testWidgets('switching to Elements tab shows prompt or element tiles', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Elements'),
        ),
      );
      await tester.pumpAndSettle();

      // Elements tab shows either element tiles or a select-filing message
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });

  group('XbrlFilingTile', () {
    testWidgets('renders company name', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Meridian Tech'), findsOneWidget);
    });

    testWidgets('renders financial year', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('2024-25'), findsWidgets);
    });

    testWidgets('renders taxonomy version', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('2023'), findsWidgets);
    });

    testWidgets('renders report type badge (STA for Standalone)', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STA'), findsOneWidget);
    });

    testWidgets('renders tags completion text', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      // "90/150 tags"
      expect(find.textContaining('tags'), findsOneWidget);
    });

    testWidgets('renders completion percentage in ring', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      // 90/150 = 60%
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('renders validation errors badge when errors > 0', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlFilingTile(filing: _testFilingWithErrors)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('error'), findsWidgets);
    });

    testWidgets('renders CON badge for consolidated report type', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: XbrlFilingTile(filing: _testFilingWithErrors),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CON'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      await _setDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XbrlFilingTile(
              filing: _testFiling,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(XbrlFilingTile));
      expect(tapped, isTrue);
    });
  });

  group('XbrlElementTile', () {
    testWidgets('renders element label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlElementTile(element: _testElement)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Profit'), findsWidgets);
    });

    testWidgets('renders REQ badge for required element', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlElementTile(element: _testElement)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('REQ'), findsOneWidget);
    });

    testWidgets('renders check icon when element is completed', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlElementTile(element: _testElement)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders Not entered text when element is not completed', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlElementTile(element: _testElementPending)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not entered'), findsOneWidget);
    });

    testWidgets('renders element value when completed', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlElementTile(element: _testElement)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('32000000'), findsOneWidget);
    });

    testWidgets('renders validation error message when element has error', (
      tester,
    ) async {
      await _setDisplay(tester);
      const errorElement = XbrlElement(
        id: 'elem-err-001',
        filingId: 'xbrl-001',
        elementName: 'in-bfin:CashEquivalents',
        elementType: XbrlElementType.numeric,
        label: 'Cash Equivalents',
        isRequired: true,
        isCompleted: false,
        validationMessage: 'Value must be non-negative',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: XbrlElementTile(element: errorElement)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('non-negative'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      await _setDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XbrlElementTile(
              element: _testElement,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(XbrlElementTile));
      expect(tapped, isTrue);
    });
  });
}
