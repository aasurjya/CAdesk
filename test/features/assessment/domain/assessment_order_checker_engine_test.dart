import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_order_verification.dart';
import 'package:ca_app/features/assessment/domain/models/order_discrepancy.dart';
import 'package:ca_app/features/assessment/domain/services/assessment_order_checker_engine.dart';

void main() {
  final engine = AssessmentOrderCheckerEngine.instance;

  // ---------------------------------------------------------------------------
  // Helper builders
  // ---------------------------------------------------------------------------

  IntimationData makeIntimation({
    int assessedIncome = 1_000_000,
    int taxAssessed = 120_000,
    int taxDemand = 10_000,
    int interestCharged = 2_000,
    int tdsCredited = 110_000,
    int advanceTaxCredited = 0,
    int selfAssessmentTax = 0,
    List<AdjustmentItem> adjustments = const [],
  }) {
    return IntimationData(
      panNumber: 'ABCDE1234F',
      assessmentYear: '2023-24',
      assessedIncome: assessedIncome,
      taxAssessed: taxAssessed,
      taxDemand: taxDemand,
      interestCharged: interestCharged,
      tdsCredited: tdsCredited,
      advanceTaxCredited: advanceTaxCredited,
      selfAssessmentTax: selfAssessmentTax,
      adjustments: adjustments,
    );
  }

  ItrData makeItr({
    int filedIncome = 1_000_000,
    int taxOnIncome = 120_000,
    int tdsClaimed = 110_000,
    int advanceTaxClaimed = 0,
    int selfAssessmentTax = 0,
  }) {
    return ItrData(
      panNumber: 'ABCDE1234F',
      assessmentYear: '2023-24',
      filedIncome: filedIncome,
      taxOnIncome: taxOnIncome,
      tdsClaimed: tdsClaimed,
      advanceTaxClaimed: advanceTaxClaimed,
      selfAssessmentTax: selfAssessmentTax,
    );
  }

  // ---------------------------------------------------------------------------
  // verifyIntimation143_1
  // ---------------------------------------------------------------------------
  group('AssessmentOrderCheckerEngine.verifyIntimation143_1', () {
    test('correct intimation → result is VerificationResult.correct', () {
      final result = engine.verifyIntimation143_1(makeIntimation(), makeItr());
      expect(result.verificationResult, VerificationResult.correct);
      expect(result.discrepancies, isEmpty);
      expect(result.orderType, OrderType.intimation143_1);
    });

    test('income mismatch → discrepancy added with correct fields', () {
      final result = engine.verifyIntimation143_1(
        makeIntimation(assessedIncome: 1_100_000),
        makeItr(filedIncome: 1_000_000),
      );
      expect(result.verificationResult, VerificationResult.discrepancy);
      expect(result.discrepancies, isNotEmpty);
      final disc = result.discrepancies.first;
      expect(disc.filedAmount, 1_000_000);
      expect(disc.assessedAmount, 1_100_000);
      expect(disc.difference, 100_000);
    });

    test('TDS mismatch → discrepancy with section "TDS Credit"', () {
      final result = engine.verifyIntimation143_1(
        makeIntimation(tdsCredited: 100_000),
        makeItr(tdsClaimed: 110_000),
      );
      expect(result.verificationResult, VerificationResult.needsRectification);
      final tdsDisc = result.discrepancies
          .where((d) => d.section.contains('TDS'))
          .toList();
      expect(tdsDisc, isNotEmpty);
      expect(tdsDisc.first.filedAmount, 110_000);
      expect(tdsDisc.first.assessedAmount, 100_000);
    });

    test('advance tax mismatch → discrepancy', () {
      final result = engine.verifyIntimation143_1(
        makeIntimation(advanceTaxCredited: 50_000),
        makeItr(advanceTaxClaimed: 60_000),
      );
      expect(result.verificationResult, isNot(VerificationResult.correct));
      final atDisc = result.discrepancies
          .where((d) => d.section.contains('Advance Tax'))
          .toList();
      expect(atDisc, isNotEmpty);
    });

    test('result model has correct PAN and AY', () {
      final result = engine.verifyIntimation143_1(makeIntimation(), makeItr());
      expect(result.panNumber, 'ABCDE1234F');
      expect(result.assessmentYear, '2023-24');
    });

    test('result carries filedIncome and assessedIncome', () {
      final result = engine.verifyIntimation143_1(
        makeIntimation(assessedIncome: 1_200_000),
        makeItr(filedIncome: 1_000_000),
      );
      expect(result.filedIncome, 1_000_000);
      expect(result.assessedIncome, 1_200_000);
    });
  });

  // ---------------------------------------------------------------------------
  // computeInterest143_1A
  // ---------------------------------------------------------------------------
  group('AssessmentOrderCheckerEngine.computeInterest143_1A', () {
    test('payment made on due date → zero interest', () {
      final due = DateTime(2023, 8, 1);
      final paid = DateTime(2023, 8, 1);
      expect(engine.computeInterest143_1A(100_000_00, due, paid), 0);
    });

    test('1 month overdue → 1% of demand', () {
      final due = DateTime(2023, 8, 1);
      final paid = DateTime(2023, 9, 1);
      // demand 10000 paise, 1% = 100 paise
      final interest = engine.computeInterest143_1A(10_000, due, paid);
      expect(interest, 100);
    });

    test('part of month counts as full month (3.5 months → 4 months)', () {
      final due = DateTime(2023, 8, 1);
      final paid = DateTime(2023, 11, 15); // 3 months + 14 days
      final interest = engine.computeInterest143_1A(100_000, due, paid);
      // 4 months * 1% = 4000
      expect(interest, 4_000);
    });

    test('zero demand → zero interest', () {
      final due = DateTime(2023, 8, 1);
      final paid = DateTime(2023, 12, 1);
      expect(engine.computeInterest143_1A(0, due, paid), 0);
    });

    test('paid before due date → zero interest (no negative interest)', () {
      final due = DateTime(2023, 8, 1);
      final paid = DateTime(2023, 7, 15);
      expect(engine.computeInterest143_1A(100_000, due, paid), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // checkSection143_1Adjustments
  // ---------------------------------------------------------------------------
  group('AssessmentOrderCheckerEngine.checkSection143_1Adjustments', () {
    test('no adjustments → empty list', () {
      final discrepancies = engine.checkSection143_1Adjustments(
        makeIntimation(adjustments: []),
      );
      expect(discrepancies, isEmpty);
    });

    test('disallowance under Sec14A → creates discrepancy', () {
      final adjustments = [
        const AdjustmentItem(
          type: AdjustmentType.disallowanceSec14A,
          amount: 20_000,
          description: 'Sec 14A disallowance',
        ),
      ];
      final discrepancies = engine.checkSection143_1Adjustments(
        makeIntimation(adjustments: adjustments),
      );
      expect(discrepancies, isNotEmpty);
      expect(discrepancies.any((d) => d.section.contains('14A')), isTrue);
    });

    test('incorrect depreciation adjustment → creates discrepancy', () {
      final adjustments = [
        const AdjustmentItem(
          type: AdjustmentType.incorrectDepreciation,
          amount: 50_000,
          description: 'Depreciation reduced',
        ),
      ];
      final discrepancies = engine.checkSection143_1Adjustments(
        makeIntimation(adjustments: adjustments),
      );
      expect(
        discrepancies.any((d) => d.section.contains('Depreciation')),
        isTrue,
      );
    });

    test('multiple adjustments → multiple discrepancies', () {
      final adjustments = [
        const AdjustmentItem(
          type: AdjustmentType.disallowanceSec14A,
          amount: 20_000,
          description: 'Sec 14A',
        ),
        const AdjustmentItem(
          type: AdjustmentType.incorrectDepreciation,
          amount: 30_000,
          description: 'Depreciation',
        ),
      ];
      final discrepancies = engine.checkSection143_1Adjustments(
        makeIntimation(adjustments: adjustments),
      );
      expect(discrepancies.length, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // Model immutability
  // ---------------------------------------------------------------------------
  group('AssessmentOrderVerification — model', () {
    test('copyWith returns new instance with changed field', () {
      const original = AssessmentOrderVerification(
        panNumber: 'ABCDE1234F',
        assessmentYear: '2023-24',
        orderType: OrderType.intimation143_1,
        filedIncome: 1_000_000,
        assessedIncome: 1_000_000,
        taxDemand: 0,
        interestCharged: 0,
        penaltyLeviable: 0,
        verificationResult: VerificationResult.correct,
        discrepancies: [],
      );
      final updated = original.copyWith(taxDemand: 5_000);
      expect(updated.taxDemand, 5_000);
      expect(original.taxDemand, 0); // immutable
    });

    test('equality is structural', () {
      const v = AssessmentOrderVerification(
        panNumber: 'ABCDE1234F',
        assessmentYear: '2023-24',
        orderType: OrderType.intimation143_1,
        filedIncome: 0,
        assessedIncome: 0,
        taxDemand: 0,
        interestCharged: 0,
        penaltyLeviable: 0,
        verificationResult: VerificationResult.correct,
        discrepancies: [],
      );
      const v2 = AssessmentOrderVerification(
        panNumber: 'ABCDE1234F',
        assessmentYear: '2023-24',
        orderType: OrderType.intimation143_1,
        filedIncome: 0,
        assessedIncome: 0,
        taxDemand: 0,
        interestCharged: 0,
        penaltyLeviable: 0,
        verificationResult: VerificationResult.correct,
        discrepancies: [],
      );
      expect(v, equals(v2));
    });

    test('hashCode is consistent', () {
      const v = AssessmentOrderVerification(
        panNumber: 'ABCDE1234F',
        assessmentYear: '2023-24',
        orderType: OrderType.intimation143_1,
        filedIncome: 0,
        assessedIncome: 0,
        taxDemand: 0,
        interestCharged: 0,
        penaltyLeviable: 0,
        verificationResult: VerificationResult.correct,
        discrepancies: [],
      );
      expect(v.hashCode, v.hashCode);
    });
  });

  group('OrderDiscrepancy — model', () {
    test('copyWith returns new instance', () {
      const d = OrderDiscrepancy(
        section: 'TDS Credit',
        filedAmount: 10_000,
        assessedAmount: 9_000,
        difference: 1_000,
        reason: 'Form 26AS mismatch',
      );
      final updated = d.copyWith(reason: 'Updated reason');
      expect(updated.reason, 'Updated reason');
      expect(d.reason, 'Form 26AS mismatch');
    });

    test('equality is structural', () {
      const a = OrderDiscrepancy(
        section: 'TDS Credit',
        filedAmount: 10_000,
        assessedAmount: 9_000,
        difference: 1_000,
        reason: 'mismatch',
      );
      const b = OrderDiscrepancy(
        section: 'TDS Credit',
        filedAmount: 10_000,
        assessedAmount: 9_000,
        difference: 1_000,
        reason: 'mismatch',
      );
      expect(a, equals(b));
    });
  });
}
