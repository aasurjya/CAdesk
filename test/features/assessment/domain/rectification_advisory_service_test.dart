import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_order_verification.dart';
import 'package:ca_app/features/assessment/domain/models/order_discrepancy.dart';
import 'package:ca_app/features/assessment/domain/services/rectification_advisory_service.dart';

void main() {
  final svc = RectificationAdvisoryService.instance;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  AssessmentOrderVerification makeVerification({
    OrderType orderType = OrderType.intimation143_1,
    VerificationResult result = VerificationResult.needsRectification,
    List<OrderDiscrepancy> discrepancies = const [],
    DateTime? orderDate,
  }) {
    return AssessmentOrderVerification(
      panNumber: 'ABCDE1234F',
      assessmentYear: '2023-24',
      orderType: orderType,
      filedIncome: 1_000_000,
      assessedIncome: 1_100_000,
      taxDemand: 10_000,
      interestCharged: 2_000,
      penaltyLeviable: 0,
      verificationResult: result,
      discrepancies: discrepancies,
      orderDate: orderDate ?? DateTime(2023, 10, 1),
    );
  }

  // ---------------------------------------------------------------------------
  // generateAdvisory
  // ---------------------------------------------------------------------------
  group('RectificationAdvisoryService.generateAdvisory', () {
    test('correct verification → advisory with no action required', () {
      final v = makeVerification(
        result: VerificationResult.correct,
        discrepancies: [],
      );
      final advisory = svc.generateAdvisory(v);
      expect(advisory.requiresAction, isFalse);
      expect(advisory.grounds, isEmpty);
    });

    test('TDS discrepancy → advisory has TDS mismatch ground', () {
      final v = makeVerification(
        discrepancies: [
          const OrderDiscrepancy(
            section: 'TDS Credit',
            filedAmount: 110_000,
            assessedAmount: 100_000,
            difference: 10_000,
            reason: 'Form 26AS mismatch',
          ),
        ],
      );
      final advisory = svc.generateAdvisory(v);
      expect(advisory.requiresAction, isTrue);
      expect(
        advisory.grounds.any((g) => g == RectificationGround.tdsMismatch),
        isTrue,
      );
    });

    test(
      'advance tax discrepancy → advisory has advance tax credit ground',
      () {
        final v = makeVerification(
          discrepancies: [
            const OrderDiscrepancy(
              section: 'Advance Tax Credit',
              filedAmount: 60_000,
              assessedAmount: 50_000,
              difference: 10_000,
              reason: 'Advance tax credit reduced',
            ),
          ],
        );
        final advisory = svc.generateAdvisory(v);
        expect(
          advisory.grounds.any(
            (g) => g == RectificationGround.advanceTaxCredit,
          ),
          isTrue,
        );
      },
    );

    test('arithmetical error discrepancy → arithmetical error ground', () {
      final v = makeVerification(
        discrepancies: [
          const OrderDiscrepancy(
            section: 'Arithmetical Error',
            filedAmount: 5_000,
            assessedAmount: 6_000,
            difference: 1_000,
            reason: 'Computation error',
          ),
        ],
      );
      final advisory = svc.generateAdvisory(v);
      expect(
        advisory.grounds.any((g) => g == RectificationGround.arithmeticalError),
        isTrue,
      );
    });

    test('incorrect AY discrepancy → incorrect AY ground', () {
      final v = makeVerification(
        discrepancies: [
          const OrderDiscrepancy(
            section: 'Assessment Year',
            filedAmount: 0,
            assessedAmount: 0,
            difference: 0,
            reason: 'Wrong assessment year',
          ),
        ],
      );
      final advisory = svc.generateAdvisory(v);
      expect(
        advisory.grounds.any((g) => g == RectificationGround.incorrectAY),
        isTrue,
      );
    });

    test('multiple discrepancies → multiple grounds in advisory', () {
      final v = makeVerification(
        discrepancies: [
          const OrderDiscrepancy(
            section: 'TDS Credit',
            filedAmount: 110_000,
            assessedAmount: 100_000,
            difference: 10_000,
            reason: '26AS mismatch',
          ),
          const OrderDiscrepancy(
            section: 'Arithmetical Error',
            filedAmount: 5_000,
            assessedAmount: 6_000,
            difference: 1_000,
            reason: 'Computation error',
          ),
        ],
      );
      final advisory = svc.generateAdvisory(v);
      expect(advisory.grounds.length, greaterThanOrEqualTo(2));
    });

    test('advisory contains deadline', () {
      final v = makeVerification(orderDate: DateTime(2023, 10, 1));
      final advisory = svc.generateAdvisory(v);
      expect(advisory.deadline, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // identifyRectificationGrounds
  // ---------------------------------------------------------------------------
  group('RectificationAdvisoryService.identifyRectificationGrounds', () {
    test('no discrepancies → empty grounds', () {
      final v = makeVerification(
        result: VerificationResult.correct,
        discrepancies: [],
      );
      expect(svc.identifyRectificationGrounds(v), isEmpty);
    });

    test('TDS section → tdsMismatch ground', () {
      final v = makeVerification(
        discrepancies: [
          const OrderDiscrepancy(
            section: 'TDS Credit',
            filedAmount: 1,
            assessedAmount: 2,
            difference: 1,
            reason: '',
          ),
        ],
      );
      expect(
        svc.identifyRectificationGrounds(v),
        contains(RectificationGround.tdsMismatch),
      );
    });

    test('duplicates are not added twice', () {
      final v = makeVerification(
        discrepancies: [
          const OrderDiscrepancy(
            section: 'TDS Credit',
            filedAmount: 1,
            assessedAmount: 2,
            difference: 1,
            reason: '',
          ),
          const OrderDiscrepancy(
            section: 'TDS Credit',
            filedAmount: 3,
            assessedAmount: 4,
            difference: 1,
            reason: '',
          ),
        ],
      );
      final grounds = svc.identifyRectificationGrounds(v);
      expect(
        grounds.where((g) => g == RectificationGround.tdsMismatch).length,
        1,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // computeDeadline
  // ---------------------------------------------------------------------------
  group('RectificationAdvisoryService.computeDeadline', () {
    test('143(3) order → deadline is 4 years from order date', () {
      final orderDate = DateTime(2023, 4, 1);
      final deadline = svc.computeDeadline(
        orderDate,
        OrderType.assessment143_3,
      );
      expect(deadline, DateTime(2027, 4, 1));
    });

    test('147 order → deadline is 4 years from order date', () {
      final orderDate = DateTime(2023, 6, 15);
      final deadline = svc.computeDeadline(orderDate, OrderType.reopening147);
      expect(deadline, DateTime(2027, 6, 15));
    });

    test('143(1) intimation → deadline is 4 years from order date', () {
      final orderDate = DateTime(2023, 9, 30);
      final deadline = svc.computeDeadline(
        orderDate,
        OrderType.intimation143_1,
      );
      expect(deadline, DateTime(2027, 9, 30));
    });
  });

  // ---------------------------------------------------------------------------
  // RectificationAdvisory model
  // ---------------------------------------------------------------------------
  group('RectificationAdvisory — model', () {
    test('copyWith returns new instance', () {
      final advisory = RectificationAdvisory(
        requiresAction: true,
        grounds: const [RectificationGround.tdsMismatch],
        deadline: DateTime(2027, 1, 1),
        summary: 'TDS mismatch needs rectification',
      );
      final updated = advisory.copyWith(requiresAction: false);
      expect(updated.requiresAction, isFalse);
      expect(advisory.requiresAction, isTrue);
    });

    test('equality is structural', () {
      final a = RectificationAdvisory(
        requiresAction: false,
        grounds: const [],
        deadline: DateTime(2027, 1, 1),
        summary: 'No action',
      );
      final b = RectificationAdvisory(
        requiresAction: false,
        grounds: const [],
        deadline: DateTime(2027, 1, 1),
        summary: 'No action',
      );
      expect(a, equals(b));
    });
  });
}
