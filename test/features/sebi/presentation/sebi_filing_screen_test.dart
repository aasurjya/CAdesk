import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/sebi/presentation/sebi_filing_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('SebiFilingScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows company name in app bar title', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      // Appears in both the app bar and the Company detail row
      expect(find.textContaining('InfraBuild Ltd'), findsWidgets);
    });

    testWidgets('shows SEBI prefix in app bar', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.textContaining('SEBI'), findsOneWidget);
    });

    testWidgets('shows regulation label LODR', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.text('LODR'), findsOneWidget);
    });

    testWidgets('shows Pending Review status badge', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.text('Pending Review'), findsWidgets);
    });

    testWidgets('shows filing description text', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(
        find.textContaining('Quarterly standalone and consolidated'),
        findsOneWidget,
      );
    });

    testWidgets('shows Documents section with count', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      // 4 documents in mock data
      expect(find.textContaining('Documents (4)'), findsOneWidget);
    });

    testWidgets('shows a PDF document name', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.textContaining('Limited Review Report.pdf'), findsOneWidget);
    });

    testWidgets('shows Add Document button', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.text('Add Document'), findsOneWidget);
    });

    testWidgets('shows Submission Timeline section', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.text('Submission Timeline'), findsOneWidget);
    });

    testWidgets('shows Submit Filing button', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.text('Submit Filing'), findsOneWidget);
    });

    testWidgets('shows Save Draft button', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.text('Save Draft'), findsOneWidget);
    });

    testWidgets('shows Company detail row', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(find.text('Company'), findsOneWidget);
    });

    testWidgets('shows Form Type in info card', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      expect(
        find.textContaining('Quarterly Financial Results'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Submit Filing shows snackbar', (tester) async {
      // Use a tall viewport so the action buttons are within screen bounds
      await setTestViewport(tester, size: const Size(390, 2000));
      await pumpTestWidget(
        tester,
        const SebiFilingScreen(filingId: 'sebi-fil-001'),
      );

      await tester.tap(find.text('Submit Filing'));
      await tester.pump();

      expect(
        find.textContaining('Filing submitted to BSE/NSE'),
        findsOneWidget,
      );
    });
  });
}
