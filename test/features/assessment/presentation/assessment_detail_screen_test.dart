import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/assessment/data/providers/assessment_providers.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_order.dart';
import 'package:ca_app/features/assessment/presentation/assessment_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _orderId = 'ao-001';

final _testOrder = AssessmentOrder(
  id: _orderId,
  clientId: 'acc-001',
  clientName: 'Mehta Textiles Pvt Ltd',
  pan: 'AABCM4521F',
  assessmentYear: 'AY 2022-23',
  section: AssessmentSection.section143_3,
  orderDate: DateTime(2024, 11, 15),
  demandAmount: 1850000,
  taxAssessed: 4250000,
  incomeAssessed: 14500000,
  disallowances: 2800000,
  hasErrors: true,
  verificationStatus: VerificationStatus.disputed,
  assignedTo: 'CA Suresh Agarwal',
  remarks: 'Depreciation disallowance appears incorrect',
);

/// Pumps the detail screen with the order available in the provider.
Future<void> pumpDetail(
  WidgetTester tester, {
  String orderId = _orderId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assessmentOrdersProvider.overrideWith((_) => [_testOrder]),
        interestCalculationsProvider.overrideWith((_) => const []),
      ],
      child: MaterialApp(home: AssessmentDetailScreen(orderId: orderId)),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps the detail screen with no matching order (not-found state).
Future<void> pumpNotFound(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assessmentOrdersProvider.overrideWith((_) => const []),
        interestCalculationsProvider.overrideWith((_) => const []),
      ],
      child: const MaterialApp(
        home: AssessmentDetailScreen(orderId: 'unknown-order'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AssessmentDetailScreen', () {
    testWidgets('renders without crash when order exists', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows client name in app bar title', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.textContaining('Mehta Textiles'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows PAN in order info card', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('AABCM4521F'), findsOneWidget);
    });

    testWidgets('shows assessment year', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('AY 2022-23'), findsOneWidget);
    });

    testWidgets('shows section full label', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Section 143(3) — Scrutiny'), findsOneWidget);
    });

    testWidgets('shows Tax & Demand Summary card', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Tax & Demand Summary'), findsOneWidget);
    });

    testWidgets('shows Income Assessed label', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Income Assessed'), findsOneWidget);
    });

    testWidgets('shows Demand Amount label', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Demand Amount'), findsOneWidget);
    });

    testWidgets('shows Response Timeline card', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Response Timeline'), findsOneWidget);
    });

    testWidgets('shows assigned to in order info card', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('CA Suresh Agarwal'), findsOneWidget);
    });

    testWidgets('shows Request Extension action button', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      await tester.dragUntilVisible(
        find.text('Request Extension'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request Extension'), findsOneWidget);
    });

    testWidgets('shows File Appeal button when demand amount > 0', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      await tester.dragUntilVisible(
        find.text('File Appeal'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('File Appeal'), findsOneWidget);
    });

    testWidgets('shows not-found scaffold when order does not exist', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpNotFound(tester);

      expect(find.text('Assessment order not found'), findsOneWidget);
    });

    testWidgets('shows Penalty section card', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      // Penalty section appears as a card with text about penalty or no penalty
      expect(find.textContaining('Penalty'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Go Back button in not-found state', (tester) async {
      await setTabletViewport(tester);
      await pumpNotFound(tester);

      expect(find.text('Go Back'), findsOneWidget);
    });
  });
}
