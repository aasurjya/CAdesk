import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/assessment/domain/services/interest_verification_service.dart';

void main() {
  final svc = InterestVerificationService.instance;

  // ---------------------------------------------------------------------------
  // 234A — Delayed Filing
  // ---------------------------------------------------------------------------
  group('InterestVerificationService.computeInterest234A', () {
    test('filed on due date → zero interest', () {
      final due = DateTime(2023, 7, 31);
      final filed = DateTime(2023, 7, 31);
      expect(svc.computeInterest234A(0, due, filed), 0);
    });

    test('zero tax due → zero interest regardless of delay', () {
      final due = DateTime(2023, 7, 31);
      final filed = DateTime(2023, 12, 31);
      expect(svc.computeInterest234A(0, due, filed), 0);
    });

    test('1 month delay → 1% per month', () {
      final due = DateTime(2023, 7, 31);
      final filed = DateTime(2023, 8, 31);
      // taxDue = 100_000 paise, 1 month, 1% = 1_000 paise
      expect(svc.computeInterest234A(100_000, due, filed), 1_000);
    });

    test('part month counts as full month (1.5 months → 2 months)', () {
      final due = DateTime(2023, 7, 31);
      final filed = DateTime(2023, 9, 15); // ~1.5 months
      // 2 months * 1% of 100_000 = 2_000
      expect(svc.computeInterest234A(100_000, due, filed), 2_000);
    });

    test('5 months late → 5% interest', () {
      final due = DateTime(2023, 7, 31);
      final filed = DateTime(2023, 12, 31);
      expect(svc.computeInterest234A(200_000, due, filed), 10_000);
    });

    test('filed before due date → zero interest', () {
      final due = DateTime(2023, 7, 31);
      final filed = DateTime(2023, 7, 15);
      expect(svc.computeInterest234A(100_000, due, filed), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // 234B — Advance Tax Shortfall
  // ---------------------------------------------------------------------------
  group('InterestVerificationService.computeInterest234B', () {
    test('advance tax >= 90% of assessed tax → zero interest', () {
      // 90% of 100_000 = 90_000; paid 90_000 → no shortfall
      expect(svc.computeInterest234B(100_000, 90_000), 0);
    });

    test('advance tax > 90% → zero interest', () {
      expect(svc.computeInterest234B(100_000, 95_000), 0);
    });

    test('zero advance tax paid → interest on full assessed tax', () {
      // taxDue = 100_000, advanceTax = 0 → shortfall = 100_000
      // 1% pm from April to filing (April 1 to March 31 = 12 months typical)
      // For this test: just check shortfall > 0 and result > 0
      final interest = svc.computeInterest234B(100_000, 0);
      expect(interest, greaterThan(0));
    });

    test('advance tax paid = 0, assessed = 100_000 → 12 months interest', () {
      // shortfall = 100_000, 12 months at 1% = 12_000
      expect(svc.computeInterest234B(100_000, 0), 12_000);
    });

    test('advance tax paid covers exact 90% → zero interest', () {
      expect(svc.computeInterest234B(500_000, 450_000), 0);
    });

    test('advance tax paid covers 89% → interest on shortfall', () {
      // assessed = 100_000, paid = 89_000
      // shortfall = 100_000 - 89_000 = 11_000 (since < 90%)
      // 12 months * 1% of 11_000 = 1_320
      expect(svc.computeInterest234B(100_000, 89_000), 1_320);
    });
  });

  // ---------------------------------------------------------------------------
  // 234C — Installment Deferment
  // ---------------------------------------------------------------------------
  group('InterestVerificationService.computeInterest234C', () {
    test('all installments paid on time → zero interest', () {
      // totalTaxDue = 100_000
      // Jun 15: need 15% = 15_000 → paid 15_000
      // Sep 15: cumulative 45% = 45_000 → cumPaid = 45_000
      // Dec 15: cumulative 75% = 75_000 → cumPaid = 75_000
      // Mar 15: 100% = 100_000 → cumPaid = 100_000
      final installments = [
        AdvanceTaxInstallment(
          dueDate: DateTime(2023, 6, 15),
          amountPaid: 15_000,
        ),
        AdvanceTaxInstallment(
          dueDate: DateTime(2023, 9, 15),
          amountPaid: 30_000,
        ),
        AdvanceTaxInstallment(
          dueDate: DateTime(2023, 12, 15),
          amountPaid: 30_000,
        ),
        AdvanceTaxInstallment(
          dueDate: DateTime(2024, 3, 15),
          amountPaid: 25_000,
        ),
      ];
      expect(svc.computeInterest234C(installments, 100_000), 0);
    });

    test('nothing paid → interest on all 4 installments', () {
      final installments = [
        AdvanceTaxInstallment(dueDate: DateTime(2023, 6, 15), amountPaid: 0),
        AdvanceTaxInstallment(dueDate: DateTime(2023, 9, 15), amountPaid: 0),
        AdvanceTaxInstallment(dueDate: DateTime(2023, 12, 15), amountPaid: 0),
        AdvanceTaxInstallment(dueDate: DateTime(2024, 3, 15), amountPaid: 0),
      ];
      final interest = svc.computeInterest234C(installments, 100_000);
      expect(interest, greaterThan(0));
    });

    test(
      'Jun installment missed (< 12% paid) → interest = 1% x 3 x shortfall',
      () {
        // totalTaxDue = 100_000
        // Jun: need 15%, need to have paid at least 12% = 12_000; paid = 0
        // shortfall = 15_000 - 0 = 15_000
        // interest = 1% * 3 months * 15_000 = 450
        final installments = [
          AdvanceTaxInstallment(dueDate: DateTime(2023, 6, 15), amountPaid: 0),
          AdvanceTaxInstallment(
            dueDate: DateTime(2023, 9, 15),
            amountPaid: 45_000,
          ),
          AdvanceTaxInstallment(
            dueDate: DateTime(2023, 12, 15),
            amountPaid: 30_000,
          ),
          AdvanceTaxInstallment(
            dueDate: DateTime(2024, 3, 15),
            amountPaid: 25_000,
          ),
        ];
        // Jun shortfall only: 15_000 * 3 * 1% = 450
        expect(svc.computeInterest234C(installments, 100_000), 450);
      },
    );

    test('Sep installment missed (< 36% cumulative) → interest', () {
      // totalTaxDue = 100_000
      // Jun: paid 15_000 (≥ 12%) → no interest
      // Sep: cumPaid = 15_000, need ≥ 36% = 36_000, shortfall = 45_000 - 15_000 = 30_000
      // interest = 30_000 * 3 * 1% = 900
      final installments = [
        AdvanceTaxInstallment(
          dueDate: DateTime(2023, 6, 15),
          amountPaid: 15_000,
        ),
        AdvanceTaxInstallment(dueDate: DateTime(2023, 9, 15), amountPaid: 0),
        AdvanceTaxInstallment(
          dueDate: DateTime(2023, 12, 15),
          amountPaid: 60_000,
        ),
        AdvanceTaxInstallment(
          dueDate: DateTime(2024, 3, 15),
          amountPaid: 25_000,
        ),
      ];
      expect(svc.computeInterest234C(installments, 100_000), 900);
    });

    test('empty installments → zero interest', () {
      expect(svc.computeInterest234C([], 100_000), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // 220(2) — Overdue Demand
  // ---------------------------------------------------------------------------
  group('InterestVerificationService.computeInterest220_2', () {
    test('zero days overdue → zero interest', () {
      expect(svc.computeInterest220_2(100_000, 0), 0);
    });

    test('30 days overdue → 1 month interest (1%)', () {
      // demand = 100_000, 1 month = 1% = 1_000
      expect(svc.computeInterest220_2(100_000, 30), 1_000);
    });

    test('45 days → 2 full months (part month = full month)', () {
      // 45 days = 1 month + 15 days → rounds up to 2 months
      expect(svc.computeInterest220_2(100_000, 45), 2_000);
    });

    test('zero demand → zero interest regardless of days', () {
      expect(svc.computeInterest220_2(0, 100), 0);
    });

    test('12 months overdue (360 days) → 12% of demand', () {
      // 360 days / 30 = exactly 12 months (no partial month remainder)
      expect(svc.computeInterest220_2(100_000, 360), 12_000);
    });

    test('negative days → zero interest (guards against bad input)', () {
      expect(svc.computeInterest220_2(100_000, -5), 0);
    });
  });
}
