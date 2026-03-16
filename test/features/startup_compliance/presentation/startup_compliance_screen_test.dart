import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/startup_compliance/presentation/startup_compliance_screen.dart';
import 'package:ca_app/features/startup_compliance/presentation/widgets/startup_card.dart';
import 'package:ca_app/features/startup_compliance/presentation/widgets/startup_filing_tile.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: StartupComplianceScreen()),
  );
}

Widget _buildWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final _testStartup = StartupEntity(
  id: 'su-t01',
  entityName: 'TestStart Technologies Pvt Ltd',
  dpiitNumber: 'DIPP99999',
  incorporationDate: DateTime(2021, 4, 1),
  sector: 'SaaS',
  turnover: 25000000,
  isBelow100Cr: true,
  section80IACStatus: Section80IACStatus.approved,
  taxHolidayStartYear: 2022,
  taxHolidayEndYear: 2025,
  recognitionStatus: RecognitionStatus.recognized,
  investmentRounds: [
    InvestmentRound(
      roundName: 'Seed',
      amount: 5000000,
      date: DateTime(2021, 7, 1),
      investor: 'Test Angel Fund',
    ),
  ],
);

final _testFiling = StartupFiling(
  id: 'sf-t01',
  startupId: 'su-t01',
  entityName: 'TestStart Technologies Pvt Ltd',
  filingType: StartupFilingType.annualReturn,
  dueDate: DateTime(2026, 9, 30),
  status: StartupFilingStatus.pending,
);

// ---------------------------------------------------------------------------
// StartupComplianceScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('StartupComplianceScreen', () {
    testWidgets('renders app bar with Startup Compliance title', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Startup Compliance'), findsOneWidget);
    });

    testWidgets('renders Startups, Filings, and Calendar tabs', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Startups'),
        ),
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
          matching: find.text('Calendar'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Startups tab shows summary bar with Startups metric', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Startups'), findsWidgets);
    });

    testWidgets('Startups tab shows Recognized metric', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recognized'), findsWidgets);
    });

    testWidgets('Startups tab shows IAC summary banner with 80-IAC text', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('80-IAC'), findsWidgets);
    });

    testWidgets('Startups tab shows DPIIT recognition filter chips', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Startups tab shows StartupCard list', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(StartupCard), findsWidgets);
    });

    testWidgets('switching to Filings tab shows StartupFilingTile list', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StartupFilingTile), findsWidgets);
    });

    testWidgets('Filings tab shows startup dropdown filter', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Filings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All Startups'), findsWidgets);
    });

    testWidgets('switching to Calendar tab shows upcoming deadlines heading', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Calendar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming Deadlines'), findsOneWidget);
    });

    testWidgets('Startups tab shows NovaPay Fintech from mock data', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('NovaPay'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // StartupCard tests
  // ---------------------------------------------------------------------------

  group('StartupCard', () {
    testWidgets('renders entity name', (tester) async {
      await tester.pumpWidget(_buildWidget(StartupCard(startup: _testStartup)));
      await tester.pumpAndSettle();

      expect(find.text('TestStart Technologies Pvt Ltd'), findsOneWidget);
    });

    testWidgets('renders DPIIT number badge', (tester) async {
      await tester.pumpWidget(_buildWidget(StartupCard(startup: _testStartup)));
      await tester.pumpAndSettle();

      expect(find.textContaining('DIPP99999'), findsWidgets);
    });

    testWidgets('renders Recognized status badge', (tester) async {
      await tester.pumpWidget(_buildWidget(StartupCard(startup: _testStartup)));
      await tester.pumpAndSettle();

      expect(find.text('Recognized'), findsOneWidget);
    });

    testWidgets('renders sector name', (tester) async {
      await tester.pumpWidget(_buildWidget(StartupCard(startup: _testStartup)));
      await tester.pumpAndSettle();

      expect(find.textContaining('SaaS'), findsWidgets);
    });

    testWidgets('renders Approved 80-IAC status', (tester) async {
      await tester.pumpWidget(_buildWidget(StartupCard(startup: _testStartup)));
      await tester.pumpAndSettle();

      expect(find.text('Approved'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // StartupFilingTile tests
  // ---------------------------------------------------------------------------

  group('StartupFilingTile', () {
    testWidgets('renders entity name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(StartupFilingTile(filing: _testFiling)),
      );
      await tester.pumpAndSettle();

      expect(find.text('TestStart Technologies Pvt Ltd'), findsOneWidget);
    });

    testWidgets('renders Annual Return filing type', (tester) async {
      await tester.pumpWidget(
        _buildWidget(StartupFilingTile(filing: _testFiling)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Annual Return'), findsOneWidget);
    });

    testWidgets('renders Pending status badge', (tester) async {
      await tester.pumpWidget(
        _buildWidget(StartupFilingTile(filing: _testFiling)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders due date', (tester) async {
      await tester.pumpWidget(
        _buildWidget(StartupFilingTile(filing: _testFiling)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Sep 2026'), findsWidgets);
    });
  });
}
