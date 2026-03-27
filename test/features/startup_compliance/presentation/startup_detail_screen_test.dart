import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/startup_compliance/presentation/startup_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('StartupDetailScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows entity name in AppBar', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('NeoFinTech Solutions Pvt Ltd'), findsWidgets);
    });

    testWidgets('shows CIN value', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('U72200MH2024PTC412345'), findsOneWidget);
    });

    testWidgets('shows DPIIT Recognition card', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('DPIIT Recognition'), findsOneWidget);
    });

    testWidgets('shows DPIIT status as Recognised', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.textContaining('Recognised'), findsWidgets);
    });

    testWidgets('shows DPIIT registration number', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.textContaining('DIPP12345'), findsOneWidget);
    });

    testWidgets('shows Tax Benefits card title', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('Tax Benefits & Applicability'), findsOneWidget);
    });

    testWidgets('shows Section 80-IAC row', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.textContaining('80-IAC'), findsOneWidget);
    });

    testWidgets('shows Investor Rounds card', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('Investor Rounds'), findsOneWidget);
    });

    testWidgets('shows investor names', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('AngelFund Partners'), findsOneWidget);
      expect(find.text('Venture Capital India'), findsOneWidget);
    });

    testWidgets('shows Compliance Calendar card', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('Compliance Calendar'), findsOneWidget);
    });

    testWidgets('shows compliance calendar items', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.textContaining('MGT-7A'), findsOneWidget);
      expect(find.textContaining('Income Tax Return'), findsOneWidget);
    });

    testWidgets('shows compliance progress counter', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      // 1 completed out of 5 total
      expect(find.text('1 / 5'), findsOneWidget);
    });

    testWidgets('shows sector information', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('FinTech / Digital Payments'), findsOneWidget);
    });

    testWidgets('shows round labels (Seed, Pre-Series A)', (tester) async {
      await setPhoneViewport(tester);
      await pumpTestWidget(
        tester,
        const StartupDetailScreen(startupId: 'startup-001'),
      );
      expect(find.text('Seed'), findsOneWidget);
      expect(find.text('Pre-Series A'), findsOneWidget);
    });
  });
}
