import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/tds_26qb.dart';

void main() {
  group('Tds26QB', () {
    final form = Tds26QB(
      acknowledgementNumber: '26QB202526001',
      buyerPan: 'ABCDE1234F',
      buyerName: 'Amit Gupta',
      sellerPan: 'LMNOP6789K',
      sellerName: 'Rekha Verma',
      propertyAddress: '123 MG Road, Bengaluru, Karnataka 560001',
      propertyValue: 7500000.0,
      tdsAmount: 75000.0,
      paymentDate: DateTime(2025, 9, 15),
      financialYear: '2025-26',
      assessmentYear: '2026-27',
      challanNumber: '26QB-0001',
      status: Form26QBStatus.paid,
    );

    test('creates immutable instance with correct values', () {
      expect(form.acknowledgementNumber, '26QB202526001');
      expect(form.buyerPan, 'ABCDE1234F');
      expect(form.sellerPan, 'LMNOP6789K');
      expect(form.propertyValue, 7500000.0);
      expect(form.tdsAmount, 75000.0);
      expect(form.status, Form26QBStatus.paid);
    });

    test('tdsRate returns 1% for standard property transaction', () {
      expect(form.tdsRate, closeTo(1.0, 0.001));
    });

    test('isAboveThreshold returns true when property > 50 lakh', () {
      expect(form.isAboveThreshold, isTrue);
    });

    test('isAboveThreshold returns false when property <= 50 lakh', () {
      final below = form.copyWith(propertyValue: 4999999.0);
      expect(below.isAboveThreshold, isFalse);
    });

    test('isAboveThreshold returns false at exactly 50 lakh', () {
      final exact = form.copyWith(propertyValue: 5000000.0);
      expect(exact.isAboveThreshold, isFalse);
    });

    test('computed TDS at 1% of 75 lakh = 75000', () {
      expect(form.computedTds, closeTo(75000.0, 0.01));
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = form.copyWith(status: Form26QBStatus.pending);
      expect(updated.status, Form26QBStatus.pending);
      expect(updated.buyerPan, form.buyerPan);
    });

    test('equality is value-based', () {
      final same = Tds26QB(
        acknowledgementNumber: '26QB202526001',
        buyerPan: 'ABCDE1234F',
        buyerName: 'Amit Gupta',
        sellerPan: 'LMNOP6789K',
        sellerName: 'Rekha Verma',
        propertyAddress: '123 MG Road, Bengaluru, Karnataka 560001',
        propertyValue: 7500000.0,
        tdsAmount: 75000.0,
        paymentDate: DateTime(2025, 9, 15),
        financialYear: '2025-26',
        assessmentYear: '2026-27',
        challanNumber: '26QB-0001',
        status: Form26QBStatus.paid,
      );
      expect(form, equals(same));
      expect(form.hashCode, equals(same.hashCode));
    });

    test('inequality when fields differ', () {
      final different = form.copyWith(acknowledgementNumber: '99999');
      expect(form, isNot(equals(different)));
    });

    test('Form26QBStatus has expected values', () {
      expect(Form26QBStatus.values, contains(Form26QBStatus.pending));
      expect(Form26QBStatus.values, contains(Form26QBStatus.paid));
      expect(Form26QBStatus.values, contains(Form26QBStatus.cancelled));
    });

    test('toString includes key fields', () {
      final str = form.toString();
      expect(str, contains('ABCDE1234F'));
      expect(str, contains('7500000'));
    });
  });
}
