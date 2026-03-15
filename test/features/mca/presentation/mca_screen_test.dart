import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/mca/presentation/mca_screen.dart';
import 'package:ca_app/features/mca/presentation/widgets/company_tile.dart';
import 'package:ca_app/features/mca/presentation/widgets/mca_filing_tile.dart';
import 'package:ca_app/features/mca/domain/models/company.dart';
import 'package:ca_app/features/mca/domain/models/mca_filing.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: McaScreen()));
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _testCompany = Company(
  id: 'co-test-001',
  cin: 'U74999MH2018PTC312456',
  companyName: 'Meridian Tech Solutions Private Limited',
  incorporationDate: DateTime(2018, 6, 14),
  category: CompanyCategory.privateLimited,
  paidUpCapital: 5000000,
  authorisedCapital: 10000000,
  registeredAddress: '401, Lotus Corporate Park, Mumbai 400063',
  rocJurisdiction: 'ROC Mumbai',
  status: CompanyStatus.active,
  directors: [
    Director(
      din: '08123456',
      name: 'Rajesh Kumar Sharma',
      designation: 'Managing Director',
      appointmentDate: DateTime.utc(2018, 6, 14),
    ),
  ],
);

final _testFiling = McaFiling(
  id: 'mca-test-001',
  companyId: 'co-test-001',
  companyName: 'Meridian Tech Solutions Private Limited',
  cin: 'U74999MH2018PTC312456',
  formType: McaFormType.mgt7,
  dueDate: DateTime(2026, 9, 30),
  status: McaFilingStatus.pending,
  financialYear: '2024-25',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('McaScreen', () {
    testWidgets('renders app bar with MCA / ROC Compliance title', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('MCA / ROC Compliance'), findsOneWidget);
    });

    testWidgets('renders Companies tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Companies'),
        ),
        findsOneWidget,
      );
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

    testWidgets('renders company tiles in Companies tab', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CompanyTile), findsWidgets);
    });

    testWidgets('renders filter icon button in app bar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    });

    testWidgets('renders New Filing FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Filing'), findsOneWidget);
    });

    testWidgets('switching to Filings tab shows filing tiles', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(McaFilingTile), findsWidgets);
    });

    testWidgets('Companies tab shows company names', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Mock data includes "Meridian Tech" and others
      expect(find.textContaining('Private Limited'), findsWidgets);
    });

    testWidgets('Companies tab shows ROC jurisdiction', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('ROC'), findsWidgets);
    });
  });

  group('CompanyTile', () {
    testWidgets('renders company name', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompanyTile(company: _testCompany)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Meridian Tech'), findsOneWidget);
    });

    testWidgets('renders formatted CIN with dashes', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompanyTile(company: _testCompany)),
        ),
      );
      await tester.pumpAndSettle();

      // U74999MH2018PTC312456 → U74999-MH-2018-PTC-312456
      expect(find.textContaining('U74999-MH-2018'), findsOneWidget);
    });

    testWidgets('renders category badge', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompanyTile(company: _testCompany)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Pvt Ltd'), findsOneWidget);
    });

    testWidgets('renders ROC jurisdiction', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompanyTile(company: _testCompany)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('ROC Mumbai'), findsOneWidget);
    });

    testWidgets('renders director count chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompanyTile(company: _testCompany)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Directors'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      await _setDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompanyTile(
              company: _testCompany,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CompanyTile));
      expect(tapped, isTrue);
    });
  });

  group('McaFilingTile', () {
    testWidgets('renders company name', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: McaFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Meridian Tech'), findsOneWidget);
    });

    testWidgets('renders form type badge label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: McaFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('MGT-7'), findsWidgets);
    });

    testWidgets('renders status label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: McaFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Pending'), findsOneWidget);
    });

    testWidgets('renders financial year label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: McaFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('2024-25'), findsWidgets);
    });

    testWidgets('renders due date', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: McaFilingTile(filing: _testFiling)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Sep'), findsWidgets);
    });

    testWidgets('fires onTap callback', (tester) async {
      await _setDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: McaFilingTile(
              filing: _testFiling,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(McaFilingTile));
      expect(tapped, isTrue);
    });

    testWidgets('renders penalty banner when penaltyAmount is set', (
      tester,
    ) async {
      await _setDisplay(tester);
      final filingWithPenalty = McaFiling(
        id: 'mca-penalty-001',
        companyId: 'co-test-001',
        companyName: 'Meridian Tech Solutions Private Limited',
        cin: 'U74999MH2018PTC312456',
        formType: McaFormType.aoc4,
        dueDate: DateTime(2025, 9, 30),
        status: McaFilingStatus.pending,
        financialYear: '2024-25',
        penaltyAmount: 10000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: McaFilingTile(filing: filingWithPenalty)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Penalty'), findsOneWidget);
    });
  });
}
