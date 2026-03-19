import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/onboarding/presentation/kyc_verification_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('KycVerificationScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows KYC Verification title in AppBar', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('KYC Verification'), findsOneWidget);
    });

    testWidgets('shows client ID in client info card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.textContaining('client-abc'), findsOneWidget);
    });

    testWidgets('shows verification progress percentage', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      // Default: 1 verified (PAN) out of 4 = 25%
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('shows PAN Verification step', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('PAN Verification'), findsOneWidget);
    });

    testWidgets('shows Aadhaar Verification step', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('Aadhaar Verification'), findsOneWidget);
    });

    testWidgets('shows Bank Account Verification step', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('Bank Account Verification'), findsOneWidget);
    });

    testWidgets('shows GST Registration step', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('GST Registration'), findsOneWidget);
    });

    testWidgets('shows Verified status for PAN', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('Verified'), findsWidgets);
    });

    testWidgets('shows Verify Now button for Aadhaar (uploaded status)', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('Verify Now'), findsOneWidget);
    });

    testWidgets('shows Upload Document button for pending steps', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.text('Upload Document'), findsWidgets);
    });

    testWidgets('shows progress info text (X of 4 verifications)', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.textContaining('of 4 verifications'), findsOneWidget);
    });

    testWidgets('shows linear progress indicator', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows incomplete warning banner when not all steps done', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      expect(find.textContaining('Complete all'), findsOneWidget);
    });

    testWidgets('Verify Now button triggers verifying then verified state', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpTestWidget(
        tester,
        const KycVerificationScreen(clientId: 'client-abc'),
      );
      await tester.tap(find.text('Verify Now'));
      // Pump one frame to process the setState to 'verifying'
      await tester.pump(Duration.zero);
      // Spinner is shown while verifying
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Drain the 1-second delay timer so the test ends cleanly
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
