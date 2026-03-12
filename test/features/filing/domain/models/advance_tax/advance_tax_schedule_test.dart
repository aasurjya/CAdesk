import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/advance_tax/advance_tax_schedule.dart';

void main() {
  group('AdvanceTaxSchedule.forFY', () {
    final schedule = AdvanceTaxSchedule.forFY(100000, 2025);

    test('creates 4 installments', () {
      expect(schedule.installments.length, 4);
    });

    test('installment percentages are 15/30/30/25', () {
      expect(schedule.installments[0].amountDue, 15000.0);
      expect(schedule.installments[1].amountDue, 30000.0);
      expect(schedule.installments[2].amountDue, 30000.0);
      expect(schedule.installments[3].amountDue, 25000.0);
    });

    test('cumulative percentages are 15/45/75/100', () {
      expect(schedule.installments[0].cumulativePercent, 15);
      expect(schedule.installments[1].cumulativePercent, 45);
      expect(schedule.installments[2].cumulativePercent, 75);
      expect(schedule.installments[3].cumulativePercent, 100);
    });

    test('all installments initialized with zero amountPaid', () {
      for (final inst in schedule.installments) {
        expect(inst.amountPaid, 0.0);
      }
    });
  });

  group('AdvanceTaxInstallment', () {
    test('shortfall = amountDue - amountPaid', () {
      final inst = AdvanceTaxSchedule.forFY(100000, 2025).installments[0];
      expect(inst.shortfall, 15000.0); // 15000 - 0
    });

    test('isPaid is true when amountPaid >= amountDue', () {
      final inst = AdvanceTaxSchedule.forFY(100000, 2025).installments[0];
      expect(inst.isPaid, isFalse);

      final paid = inst.copyWith(amountPaid: 15000);
      expect(paid.isPaid, isTrue);

      final overpaid = inst.copyWith(amountPaid: 20000);
      expect(overpaid.isPaid, isTrue);
    });
  });

  group('AdvanceTaxSchedule totals', () {
    test('totalShortfall equals estimatedTax when nothing paid', () {
      final schedule = AdvanceTaxSchedule.forFY(100000, 2025);
      expect(schedule.totalShortfall, 100000.0);
      expect(schedule.totalPaid, 0.0);
    });
  });
}
