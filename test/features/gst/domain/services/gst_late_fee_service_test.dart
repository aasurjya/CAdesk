import 'package:ca_app/features/gst/domain/models/gst_return.dart';
import 'package:ca_app/features/gst/domain/services/gst_late_fee_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GstLateFeeResult', () {
    test('creates with correct field values', () {
      final result = GstLateFeeResult(
        cgstLateFee: 250.0,
        sgstLateFee: 250.0,
        totalLateFee: 500.0,
        maxCapApplied: false,
        daysLate: 10,
      );

      expect(result.cgstLateFee, 250.0);
      expect(result.sgstLateFee, 250.0);
      expect(result.totalLateFee, 500.0);
      expect(result.maxCapApplied, false);
      expect(result.daysLate, 10);
    });
  });

  group('GstLateFeeService.calculateLateFee — GSTR-3B', () {
    test('10 days late → Rs 500 (25*10 CGST + 25*10 SGST)', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr3b,
        daysLate: 10,
        isNilReturn: false,
      );

      expect(result.cgstLateFee, 250.0);
      expect(result.sgstLateFee, 250.0);
      expect(result.totalLateFee, 500.0);
      expect(result.maxCapApplied, false);
      expect(result.daysLate, 10);
    });

    test('300 days late → capped at Rs 10,000', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr3b,
        daysLate: 300,
        isNilReturn: false,
      );

      expect(result.totalLateFee, 10000.0);
      expect(result.cgstLateFee, 5000.0);
      expect(result.sgstLateFee, 5000.0);
      expect(result.maxCapApplied, true);
    });

    test('nil return 10 days late → Rs 200 (10*10 + 10*10)', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr3b,
        daysLate: 10,
        isNilReturn: true,
      );

      expect(result.cgstLateFee, 100.0);
      expect(result.sgstLateFee, 100.0);
      expect(result.totalLateFee, 200.0);
      expect(result.maxCapApplied, false);
    });

    test('nil return 100 days late → capped at Rs 500', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr3b,
        daysLate: 100,
        isNilReturn: true,
      );

      expect(result.totalLateFee, 500.0);
      expect(result.cgstLateFee, 250.0);
      expect(result.sgstLateFee, 250.0);
      expect(result.maxCapApplied, true);
    });

    test('0 days late → Rs 0', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr3b,
        daysLate: 0,
        isNilReturn: false,
      );

      expect(result.totalLateFee, 0.0);
    });
  });

  group('GstLateFeeService.calculateLateFee — GSTR-1', () {
    test('10 days late → Rs 500', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr1,
        daysLate: 10,
        isNilReturn: false,
      );

      expect(result.totalLateFee, 500.0);
    });

    test('300 days late → capped at Rs 10,000', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr1,
        daysLate: 300,
        isNilReturn: false,
      );

      expect(result.totalLateFee, 10000.0);
      expect(result.maxCapApplied, true);
    });
  });

  group('GstLateFeeService.calculateLateFee — GSTR-9', () {
    test('10 days late with turnover Rs 10,00,000 → Rs 2,000', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr9,
        daysLate: 10,
        isNilReturn: false,
        turnoverInState: 1000000.0,
      );

      // 200 * 10 = 2000, cap = 0.25% of 10,00,000 = 2500
      expect(result.totalLateFee, 2000.0);
      expect(result.maxCapApplied, false);
    });

    test('100 days late with turnover Rs 10,00,000 → capped at Rs 2,500', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr9,
        daysLate: 100,
        isNilReturn: false,
        turnoverInState: 1000000.0,
      );

      // 200 * 100 = 20000, cap = 0.25% of 10,00,000 = 2500
      expect(result.totalLateFee, 2500.0);
      expect(result.maxCapApplied, true);
    });
  });

  group('GstLateFeeService.calculateLateFee — GSTR-9C', () {
    test('capped at 0.25% of turnover', () {
      final result = GstLateFeeService.calculateLateFee(
        returnType: GstReturnType.gstr9c,
        daysLate: 100,
        isNilReturn: false,
        turnoverInState: 1000000.0,
      );

      expect(result.totalLateFee, 2500.0);
      expect(result.maxCapApplied, true);
    });
  });

  group('GstLateFeeService.calculateInterest', () {
    test('normal interest 18% p.a. for 365 days on Rs 1,00,000', () {
      final interest = GstLateFeeService.calculateInterest(
        taxDue: 100000.0,
        daysLate: 365,
      );

      // 100000 * 18/100 * 365/365 = 18000
      expect(interest, closeTo(18000.0, 0.01));
    });

    test('RCM interest 24% p.a. for 365 days on Rs 1,00,000', () {
      final interest = GstLateFeeService.calculateInterest(
        taxDue: 100000.0,
        daysLate: 365,
        isRcm: true,
      );

      // 100000 * 24/100 * 365/365 = 24000
      expect(interest, closeTo(24000.0, 0.01));
    });

    test('0 days late → 0 interest', () {
      final interest = GstLateFeeService.calculateInterest(
        taxDue: 100000.0,
        daysLate: 0,
      );

      expect(interest, 0.0);
    });

    test('0 tax due → 0 interest', () {
      final interest = GstLateFeeService.calculateInterest(
        taxDue: 0.0,
        daysLate: 30,
      );

      expect(interest, 0.0);
    });
  });

  group('GstLateFeeService.calculateTotalPenalty', () {
    test('combines late fee + interest', () {
      final penalty = GstLateFeeService.calculateTotalPenalty(
        returnType: GstReturnType.gstr3b,
        daysLate: 10,
        isNilReturn: false,
        taxDue: 100000.0,
      );

      // Late fee: 50 * 10 = 500
      expect(penalty.lateFee.totalLateFee, 500.0);

      // Interest: 100000 * 18/100 * 10/365
      final expectedInterest = 100000.0 * 0.18 * 10 / 365;
      expect(penalty.interest, closeTo(expectedInterest, 0.01));

      // Total = late fee + interest
      expect(penalty.totalPenalty, closeTo(500.0 + expectedInterest, 0.01));
    });
  });
}
