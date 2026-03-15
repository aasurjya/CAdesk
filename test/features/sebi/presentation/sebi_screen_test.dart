import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/sebi/presentation/sebi_screen.dart';
import 'package:ca_app/features/sebi/presentation/widgets/disclosure_tile.dart';
import 'package:ca_app/features/sebi/presentation/widgets/material_event_tile.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_disclosure.dart';
import 'package:ca_app/features/sebi/domain/models/material_event.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(home: SebiScreen()),
  );
}

Widget _buildWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final _testDisclosure = SebiDisclosure(
  id: 'sebi-t01',
  clientId: 'cl-t01',
  companyName: 'Alpha Pharma Ltd',
  disclosureType: DisclosureType.quarterlyFinancial,
  exchange: StockExchange.both,
  dueDate: DateTime(2026, 4, 14),
  status: DisclosureStatus.pending,
  period: 'Q4 FY 2025-26',
  remarks: 'Audit pending',
);

final _testFiledDisclosure = SebiDisclosure(
  id: 'sebi-t02',
  clientId: 'cl-t02',
  companyName: 'Beta Corp Ltd',
  disclosureType: DisclosureType.shareholding,
  exchange: StockExchange.nse,
  dueDate: DateTime(2026, 3, 20),
  filedDate: DateTime(2026, 3, 18),
  status: DisclosureStatus.filed,
  period: 'Q3 FY 2025-26',
);

final _testMaterialEvent = MaterialEvent(
  id: 'me-t01',
  clientId: 'cl-t01',
  companyName: 'Alpha Pharma Ltd',
  eventType: MaterialEventType.acquisition,
  description: 'Acquisition of Beta Pharma for USD 100 million',
  eventDate: DateTime(2026, 3, 1),
  disclosureDeadline: DateTime(2026, 3, 3),
  isDisclosed: false,
);

// ---------------------------------------------------------------------------
// SebiScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('SebiScreen', () {
    testWidgets('renders app bar with SEBI title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('SEBI & Capital Market'), findsOneWidget);
    });

    testWidgets('renders Disclosures and Material Events tabs', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Disclosures'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Material Events'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Total summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('renders Pending summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('renders Overdue summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Overdue'), findsWidgets);
    });

    testWidgets('renders Urgent summary card', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Urgent'), findsOneWidget);
    });

    testWidgets('Disclosures tab shows DisclosureTile list', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DisclosureTile), findsWidgets);
    });

    testWidgets('status filter chips are present', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('switching to Material Events tab shows MaterialEventTile',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Material Events'));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialEventTile), findsWidgets);
    });

    testWidgets('Material Events tab shows event type filter chips',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Material Events'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Disclosures tab shows HDFC Bank disclosure', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('HDFC Bank'), findsWidgets);
    });

    testWidgets('summary cards show counts from mock data', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // 8 mock disclosures total
      expect(find.text('8'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // DisclosureTile tests
  // ---------------------------------------------------------------------------

  group('DisclosureTile', () {
    testWidgets('renders company name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(DisclosureTile(disclosure: _testDisclosure)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha Pharma Ltd'), findsOneWidget);
    });

    testWidgets('renders disclosure type badge', (tester) async {
      await tester.pumpWidget(
        _buildWidget(DisclosureTile(disclosure: _testDisclosure)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quarterly Financial'), findsOneWidget);
    });

    testWidgets('renders exchange badge BSE & NSE', (tester) async {
      await tester.pumpWidget(
        _buildWidget(DisclosureTile(disclosure: _testDisclosure)),
      );
      await tester.pumpAndSettle();

      expect(find.text('BSE & NSE'), findsOneWidget);
    });

    testWidgets('renders Pending status badge', (tester) async {
      await tester.pumpWidget(
        _buildWidget(DisclosureTile(disclosure: _testDisclosure)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders period text', (tester) async {
      await tester.pumpWidget(
        _buildWidget(DisclosureTile(disclosure: _testDisclosure)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Q4 FY 2025-26'), findsOneWidget);
    });

    testWidgets('renders filed date when disclosure is filed', (tester) async {
      await tester.pumpWidget(
        _buildWidget(DisclosureTile(disclosure: _testFiledDisclosure)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Filed:'), findsOneWidget);
    });

    testWidgets('renders remarks when present', (tester) async {
      await tester.pumpWidget(
        _buildWidget(DisclosureTile(disclosure: _testDisclosure)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Audit pending'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // MaterialEventTile tests
  // ---------------------------------------------------------------------------

  group('MaterialEventTile', () {
    testWidgets('renders company name', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MaterialEventTile(event: _testMaterialEvent)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha Pharma Ltd'), findsOneWidget);
    });

    testWidgets('renders event description', (tester) async {
      await tester.pumpWidget(
        _buildWidget(MaterialEventTile(event: _testMaterialEvent)),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Acquisition of Beta Pharma'),
        findsOneWidget,
      );
    });
  });
}
