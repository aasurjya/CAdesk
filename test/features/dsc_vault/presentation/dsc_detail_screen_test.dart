import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/dsc_vault/presentation/dsc_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// The DscDetailScreen always uses a hardcoded mock DSC (id: 'dsc-001') for
// any dscId passed in, so no provider overrides are needed.

void main() {
  group('DscDetailScreen', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.byType(DscDetailScreen), findsOneWidget);
    });

    testWidgets('shows holder name in app bar title', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.textContaining('CA Anand Verma'), findsWidgets);
    });

    testWidgets('shows DSC holder name in certificate header card', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('CA Anand Verma'), findsWidgets);
    });

    testWidgets('shows Class 3 label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('Class 3'), findsWidgets);
    });

    testWidgets('shows PAN in certificate info card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('ABCPV1234K'), findsOneWidget);
    });

    testWidgets('shows issuer name in certificate info card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('eMudhra Limited'), findsOneWidget);
    });

    testWidgets('shows Portal Associations section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('Portal Associations'), findsOneWidget);
    });

    testWidgets('shows registered portals (Income Tax and MCA)', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('Income Tax (ITD)'), findsOneWidget);
      expect(find.text('MCA (Ministry of Corporate Affairs)'), findsOneWidget);
    });

    testWidgets('shows Register button for unregistered portal (TRACES)', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('shows Recent Signings section', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('Recent Signings'), findsOneWidget);
    });

    testWidgets('shows usage history entries', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.textContaining('ITR filed for FY 2025-26'), findsOneWidget);
    });

    testWidgets('shows Renewal Reminder card', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('Renewal Reminder'), findsOneWidget);
    });

    testWidgets('shows Edit Reminder button', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.text('Edit Reminder'), findsOneWidget);
    });

    testWidgets('shows validity progress bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const DscDetailScreen(dscId: 'dsc-001'));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
