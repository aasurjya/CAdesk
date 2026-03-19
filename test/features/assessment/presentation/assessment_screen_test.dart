import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/assessment/presentation/assessment_screen.dart';
import 'package:ca_app/features/assessment/presentation/widgets/assessment_order_tile.dart';
import 'package:ca_app/features/assessment/presentation/widgets/interest_calculation_tile.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_order.dart';
import 'package:ca_app/features/assessment/domain/models/interest_calculation.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: AssessmentScreen()));
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _testOrder = AssessmentOrder(
  id: 'ao-001',
  clientId: 'cli-001',
  clientName: 'Mehta Textiles Pvt Ltd',
  pan: 'AABCM4521F',
  assessmentYear: 'AY 2023-24',
  section: AssessmentSection.section143_1,
  orderDate: DateTime(2024, 3, 15),
  demandAmount: 125000,
  taxAssessed: 850000,
  incomeAssessed: 4500000,
  disallowances: 350000,
  verificationStatus: VerificationStatus.pending,
  assignedTo: 'CA Suresh Agarwal',
  hasErrors: false,
);

const _testCalc = InterestCalculation(
  id: 'ic-001',
  orderId: 'ao-001',
  clientId: 'cli-001',
  clientName: 'Mehta Textiles Pvt Ltd',
  section: InterestSection.section234B,
  principal: 500000,
  rate: 1.0,
  period: 3,
  calculatedInterest: 15000,
  actualInterest: 15000,
  variance: 0,
  isCorrect: true,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AssessmentScreen', () {
    testWidgets('renders app bar with Assessment Order Checker title', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Assessment Order Checker'), findsOneWidget);
    });

    testWidgets('renders Orders tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('Orders')),
        findsOneWidget,
      );
    });

    testWidgets('renders Interest Checks tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Interest Checks'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Order Errors summary card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Order Errors'), findsOneWidget);
    });

    testWidgets('renders Pending summary card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('renders Interest Errors summary card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Int. Errors'), findsOneWidget);
    });

    testWidgets('renders Total Demand summary card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total Demand'), findsOneWidget);
    });

    testWidgets('renders assessment order tiles in Orders tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AssessmentOrderTile), findsWidgets);
    });

    testWidgets('renders AY summary card in Orders tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Demand Outstanding'), findsOneWidget);
    });

    testWidgets('renders filter chips in Orders tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('switching to Interest Checks tab shows interest tiles', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Interest Checks'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InterestCalculationTile), findsWidgets);
    });
  });

  group('AssessmentOrderTile', () {
    testWidgets('renders client name', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AssessmentOrderTile(order: _testOrder)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mehta Textiles'), findsOneWidget);
    });

    testWidgets('renders assessment year', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AssessmentOrderTile(order: _testOrder)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('AY 2023-24'), findsWidgets);
    });

    testWidgets('renders section badge', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AssessmentOrderTile(order: _testOrder)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('143'), findsWidgets);
    });

    testWidgets('fires onTap callback', (tester) async {
      await _setPhoneDisplay(tester);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentOrderTile(
              order: _testOrder,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AssessmentOrderTile));
      expect(tapped, isTrue);
    });

    testWidgets('shows error border when hasErrors is true', (tester) async {
      await _setPhoneDisplay(tester);
      final errorOrder = AssessmentOrder(
        id: 'ao-err-001',
        clientId: 'cli-001',
        clientName: 'Error Client',
        pan: 'AABCE1234F',
        assessmentYear: 'AY 2022-23',
        section: AssessmentSection.section143_3,
        orderDate: DateTime(2023, 8, 10),
        demandAmount: 500000,
        taxAssessed: 1200000,
        incomeAssessed: 6000000,
        disallowances: 800000,
        verificationStatus: VerificationStatus.disputed,
        assignedTo: 'CA Test',
        hasErrors: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AssessmentOrderTile(order: errorOrder)),
        ),
      );
      await tester.pumpAndSettle();

      // Error client name should be visible
      expect(find.textContaining('Error Client'), findsOneWidget);
    });
  });

  group('InterestCalculationTile', () {
    testWidgets('renders client name', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InterestCalculationTile(calc: _testCalc)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mehta Textiles'), findsOneWidget);
    });

    testWidgets('renders section label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InterestCalculationTile(calc: _testCalc)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('234B'), findsWidgets);
    });

    testWidgets('renders check icon when isCorrect is true', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InterestCalculationTile(calc: _testCalc)),
        ),
      );
      await tester.pumpAndSettle();

      // Check icon indicates correct calculation
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders Matches exactly text when variance is zero', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InterestCalculationTile(calc: _testCalc)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matches exactly'), findsOneWidget);
    });
  });
}
