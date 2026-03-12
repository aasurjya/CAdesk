import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/tds_26qb.dart';
import 'package:ca_app/features/tds/domain/services/form_26qb_service.dart';

void main() {
  group('Form26QBService', () {
    group('computeTds', () {
      test('computes 1% TDS on property above 50 lakh', () {
        final result = Form26QBService.computeTds(propertyValue: 7500000.0);
        expect(result.tdsAmount, closeTo(75000.0, 0.01));
        expect(result.tdsRate, closeTo(1.0, 0.001));
        expect(result.isLiable, isTrue);
      });

      test('no TDS when property value is exactly 50 lakh', () {
        final result = Form26QBService.computeTds(propertyValue: 5000000.0);
        expect(result.tdsAmount, 0.0);
        expect(result.isLiable, isFalse);
      });

      test('no TDS when property value is below 50 lakh', () {
        final result = Form26QBService.computeTds(propertyValue: 4999999.0);
        expect(result.tdsAmount, 0.0);
        expect(result.isLiable, isFalse);
      });

      test('computes TDS for a 1 crore property', () {
        final result = Form26QBService.computeTds(propertyValue: 10000000.0);
        expect(result.tdsAmount, closeTo(100000.0, 0.01));
      });

      test('computes TDS for joint buyers (each above threshold)', () {
        // Two buyers, each paying 40L for a 80L property.
        // As each buyer's share > 50L, TDS applies on each share.
        final result = Form26QBService.computeTds(
          propertyValue: 8000000.0,
          numberOfBuyers: 2,
        );
        // Each buyer's share = 40L > 50L → 1% on 80L total = 80000
        expect(result.tdsAmount, closeTo(80000.0, 0.01));
      });
    });

    group('validate', () {
      final validForm = Tds26QB(
        acknowledgementNumber: '26QB202526001',
        buyerPan: 'ABCDE1234F',
        buyerName: 'Amit Gupta',
        sellerPan: 'LMNOP6789K',
        sellerName: 'Rekha Verma',
        propertyAddress: '123 MG Road, Bengaluru',
        propertyValue: 7500000.0,
        tdsAmount: 75000.0,
        paymentDate: DateTime(2025, 9, 15),
        financialYear: '2025-26',
        assessmentYear: '2026-27',
        challanNumber: '26QB-0001',
        status: Form26QBStatus.paid,
      );

      test('valid form returns empty error list', () {
        final errors = Form26QBService.validate(validForm);
        expect(errors, isEmpty);
      });

      test('invalid buyer PAN is flagged', () {
        final invalid = validForm.copyWith(buyerPan: 'INVALID');
        final errors = Form26QBService.validate(invalid);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('buyer PAN')), isTrue);
      });

      test('invalid seller PAN is flagged', () {
        final invalid = validForm.copyWith(sellerPan: 'INVALID');
        final errors = Form26QBService.validate(invalid);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('seller PAN')), isTrue);
      });

      test('property below threshold flagged when TDS is claimed', () {
        final invalid = validForm.copyWith(
          propertyValue: 4000000.0,
          tdsAmount: 40000.0,
        );
        final errors = Form26QBService.validate(invalid);
        expect(errors, isNotEmpty);
      });

      test('TDS amount mismatch is flagged', () {
        // Property 75L, TDS should be 75000, but provided 50000
        final invalid = validForm.copyWith(tdsAmount: 50000.0);
        final errors = Form26QBService.validate(invalid);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('tds')), isTrue);
      });
    });

    group('generateAcknowledgementNumber', () {
      test('generates formatted acknowledgement number', () {
        final num = Form26QBService.generateAcknowledgementNumber(
          financialYear: '2025-26',
          sequenceNumber: 42,
        );
        expect(num, '26QB202526042');
      });
    });
  });
}
