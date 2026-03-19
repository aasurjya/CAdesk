import 'package:ca_app/features/nri_tax/presentation/nri_computation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  const clientId = 'test-client-1';

  group('NriComputationScreen - renders', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows client name in AppBar title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('Rajiv Kapoor'), findsWidgets);
    });

    testWidgets('shows "NRI Tax —" prefix in AppBar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('NRI Tax'), findsOneWidget);
    });
  });

  group('NriComputationScreen - residential status card', () {
    testWidgets('shows "Non-Resident (NRI)" status badge', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Non-Resident (NRI)'), findsOneWidget);
    });

    testWidgets('shows PAN number', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('ABCPK5678L'), findsOneWidget);
    });

    testWidgets('shows country of residence "United States"', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('United States'), findsWidgets);
    });
  });

  group('NriComputationScreen - days in India card', () {
    testWidgets('shows "Days in India — History" section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Days in India — History'), findsOneWidget);
    });

    testWidgets('shows NRI threshold hint text', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('182 days'), findsOneWidget);
    });

    testWidgets('shows FY entries in days history', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('FY 2025-26'), findsOneWidget);
    });
  });

  group('NriComputationScreen - income categorization', () {
    testWidgets('shows "Income Categorization" section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Income Categorization'), findsOneWidget);
    });

    testWidgets('shows taxable income total label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('Taxable:'), findsOneWidget);
    });

    testWidgets('shows House Property income item', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('House Property'), findsOneWidget);
    });
  });

  group('NriComputationScreen - DTAA card', () {
    testWidgets('shows "DTAA Benefits" section header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('DTAA Benefits'), findsOneWidget);
    });

    testWidgets('shows Article 10 — Dividends entry', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.textContaining('Article 10'), findsOneWidget);
    });
  });

  group('NriComputationScreen - document requirements', () {
    testWidgets('shows "Document Requirements" section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Document Requirements'), findsOneWidget);
    });

    testWidgets('shows Tax Residency Certificate row', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Tax Residency Certificate (TRC)'), findsOneWidget);
    });

    testWidgets('shows Form 10F row', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Form 10F'), findsOneWidget);
    });
  });

  group('NriComputationScreen - relief computation', () {
    testWidgets('shows "Relief Computation" section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Relief Computation'), findsOneWidget);
    });

    testWidgets('shows Section 90 label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Section 90'), findsOneWidget);
    });

    testWidgets('shows Section 91 label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Section 91'), findsOneWidget);
    });
  });

  group('NriComputationScreen - action buttons', () {
    testWidgets('shows "Export Computation" button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('Export Computation'), findsOneWidget);
    });

    testWidgets('shows "File Form 10F" button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const NriComputationScreen(clientId: clientId),
      );
      expect(find.text('File Form 10F'), findsOneWidget);
    });
  });
}
