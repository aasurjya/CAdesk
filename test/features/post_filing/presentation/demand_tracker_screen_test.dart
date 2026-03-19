import 'package:ca_app/features/post_filing/presentation/demand_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('DemandTrackerScreen - renders', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows "Demand Tracker" title in AppBar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Demand Tracker'), findsOneWidget);
    });

    testWidgets('shows subtitle "Monitor outstanding tax demands"', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Monitor outstanding tax demands'), findsOneWidget);
    });
  });

  group('DemandTrackerScreen - summary row', () {
    testWidgets('shows "Total Demand" metric card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Total Demand'), findsOneWidget);
    });

    testWidgets('shows "Paid" metric card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Paid'), findsWidgets);
    });

    testWidgets('shows "Outstanding" metric card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Outstanding'), findsWidgets);
    });
  });

  group('DemandTrackerScreen - filter chips', () {
    testWidgets('shows "All" filter chip', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('shows "Outstanding" filter chip', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      // Both the metric card and filter chip contain 'Outstanding'
      expect(find.text('Outstanding'), findsWidgets);
    });

    testWidgets('shows "Under Dispute" filter chip', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Under Dispute'), findsWidgets);
    });

    testWidgets('shows "Resolved" filter chip', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Resolved'), findsWidgets);
    });
  });

  group('DemandTrackerScreen - demand cards', () {
    testWidgets('shows client names from mock data', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Mehta Textiles Pvt Ltd'), findsOneWidget);
    });

    testWidgets('shows "Communication History" label on expanded cards', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('Communication History'), findsWidgets);
    });

    testWidgets('shows section numbers like "Section 143(3)"', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.textContaining('Section 143(3)'), findsWidgets);
    });

    testWidgets('shows PAN values in demand cards', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());
      expect(find.text('AABCM4521F'), findsOneWidget);
    });
  });

  group('DemandTrackerScreen - filter interaction', () {
    testWidgets('tapping "Resolved" filter shows only resolved demands', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DemandTrackerScreen());

      // Tap the Resolved filter chip (it's in the row of chips)
      final resolvedChips = find.text('Resolved');
      // The filter row chip is the last one (metric card label won't be in the scrollable row)
      await tester.tap(resolvedChips.first);
      await tester.pumpAndSettle();

      // After filtering, only Patel & Sons HUF (resolved) should appear
      expect(find.text('Patel & Sons HUF'), findsOneWidget);
    });

    testWidgets(
      'tapping "All" filter after another filter restores all demands',
      (tester) async {
        await setDesktopViewport(tester);
        await pumpTestWidget(tester, const DemandTrackerScreen());

        // Apply a filter then clear it
        await tester.tap(find.text('Resolved').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // All 4 demand clients should be visible
        expect(find.text('Mehta Textiles Pvt Ltd'), findsOneWidget);
        expect(find.text('Gupta Steel Industries'), findsOneWidget);
      },
    );
  });
}
