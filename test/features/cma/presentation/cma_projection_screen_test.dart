import 'package:ca_app/features/cma/presentation/cma_projection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('CmaProjectionScreen - renders', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows "CMA Projections" in AppBar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('CMA Projections'), findsOneWidget);
    });

    testWidgets('shows PDF export icon in AppBar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.byIcon(Icons.picture_as_pdf_rounded), findsWidgets);
    });
  });

  group('CmaProjectionScreen - bank header', () {
    testWidgets('shows bank name "State Bank of India"', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('State Bank of India'), findsOneWidget);
    });

    testWidgets('shows 5-year CMA projection label by default', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('5-year CMA projection'), findsOneWidget);
    });
  });

  group('CmaProjectionScreen - inputs section', () {
    testWidgets('shows "Projection Inputs" section title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Projection Inputs'), findsOneWidget);
    });

    testWidgets('shows Base Revenue slider label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Base Revenue'), findsOneWidget);
    });

    testWidgets('shows Revenue Growth slider label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Revenue Growth'), findsOneWidget);
    });

    testWidgets('shows Projection year chips (3Y, 5Y, 7Y)', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('3 Y'), findsOneWidget);
      expect(find.text('5 Y'), findsOneWidget);
      expect(find.text('7 Y'), findsOneWidget);
    });
  });

  group('CmaProjectionScreen - projected financials', () {
    testWidgets('shows "Projected Financials" section title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Projected Financials'), findsOneWidget);
    });

    testWidgets('shows DataTable with Year column header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Year'), findsOneWidget);
    });

    testWidgets('shows DataTable with Sales column header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Sales'), findsOneWidget);
    });

    testWidgets('shows DataTable with Net Profit column header', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Net Profit'), findsOneWidget);
    });
  });

  group('CmaProjectionScreen - key ratios', () {
    testWidgets('shows "Key Ratios" section title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Key Ratios'), findsOneWidget);
    });

    testWidgets('shows Current Ratio label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Current Ratio'), findsOneWidget);
    });

    testWidgets('shows D/E Ratio label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('D/E Ratio'), findsOneWidget);
    });
  });

  group('CmaProjectionScreen - export button', () {
    testWidgets('shows "Export CMA Report" button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      expect(find.text('Export CMA Report'), findsWidgets);
    });

    testWidgets('tapping export button shows snackbar', (tester) async {
      await setTestViewport(tester, size: const Size(1440, 2000));
      await pumpTestWidget(tester, const CmaProjectionScreen());
      // Scroll to ensure the FilledButton is visible
      final exportButton = find.text('Export CMA Report').last;
      await tester.ensureVisible(exportButton);
      await tester.pumpAndSettle();
      await tester.tap(exportButton);
      await tester.pump();
      expect(find.textContaining('CMA report'), findsOneWidget);
    });
  });

  group('CmaProjectionScreen - projection year toggle', () {
    testWidgets('switching to 3Y shows "3-year CMA projection"', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const CmaProjectionScreen());
      await tester.tap(find.text('3 Y'));
      await tester.pumpAndSettle();
      expect(find.text('3-year CMA projection'), findsOneWidget);
    });
  });
}
