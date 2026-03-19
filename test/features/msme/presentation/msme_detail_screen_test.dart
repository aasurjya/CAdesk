import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/msme/presentation/msme_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('MsmeDetailScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows entity name in AppBar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('PrecisionParts India Pvt Ltd'), findsWidgets);
    });

    testWidgets('shows Udyam registration number', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('UDYAM-MH-01-0012345'), findsOneWidget);
    });

    testWidgets('shows MSME category badge (Small)', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('shows activity type', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.textContaining('Manufacturing'), findsOneWidget);
    });

    testWidgets('shows payment summary card with Total label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Overdue'), findsWidgets);
      expect(find.text('Outstanding'), findsOneWidget);
    });

    testWidgets('shows Section 43B(h) banner', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.textContaining('43B'), findsOneWidget);
    });

    testWidgets('shows Section 43B(h) 45-day rule text', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.textContaining('45 days'), findsWidgets);
    });

    testWidgets('shows Vendor Payment Aging card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('Vendor Payment Aging'), findsOneWidget);
    });

    testWidgets('shows vendor names in payment list', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('Steel Corp India'), findsOneWidget);
      expect(find.text('Bolt & Nut Supplies'), findsOneWidget);
    });

    testWidgets('shows Paid and Pending status badges', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('Paid'), findsWidgets);
      // "Pending" badges may be off-screen on CI; check including off-stage.
      expect(
        find.text('Pending', skipOffstage: false),
        findsWidgets,
      );
    });

    testWidgets('shows Interest on Delayed Payments card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('Interest on Delayed Payments'), findsOneWidget);
    });

    testWidgets('shows Total Interest Liability label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.textContaining('Total Interest Liability'), findsOneWidget);
    });

    testWidgets('shows NIC code', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('shows aging days for vendors', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const MsmeDetailScreen(msmeId: 'msme-001'));
      expect(find.textContaining('Aging:'), findsWidgets);
    });
  });
}
