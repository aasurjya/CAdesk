import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';

void main() {
  group('FvuDeducteeRecord', () {
    const record = FvuDeducteeRecord(
      pan: 'ABCDE1234F',
      deducteeName: 'John Doe',
      amountPaid: 100000.00,
      tdsAmount: 10000.00,
      dateOfPayment: '15022026',
      sectionCode: '194J',
      deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
    );

    test('creates immutable instance with correct values', () {
      expect(record.pan, 'ABCDE1234F');
      expect(record.deducteeName, 'John Doe');
      expect(record.amountPaid, 100000.00);
      expect(record.tdsAmount, 10000.00);
      expect(record.dateOfPayment, '15022026');
      expect(record.sectionCode, '194J');
      expect(record.deducteeTypeCode, FvuDeducteeTypeCode.nonCompany);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = record.copyWith(tdsAmount: 12000.00);
      expect(updated.tdsAmount, 12000.00);
      expect(updated.pan, record.pan);
    });

    test('equality is value-based', () {
      const same = FvuDeducteeRecord(
        pan: 'ABCDE1234F',
        deducteeName: 'John Doe',
        amountPaid: 100000.00,
        tdsAmount: 10000.00,
        dateOfPayment: '15022026',
        sectionCode: '194J',
        deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
      );
      expect(record, equals(same));
      expect(record.hashCode, equals(same.hashCode));
    });

    test('inequality when fields differ', () {
      final different = record.copyWith(pan: 'ZZZZZ9999Z');
      expect(record, isNot(equals(different)));
    });

    test('PANNOTAVBL accepted as pan value', () {
      const noPan = FvuDeducteeRecord(
        pan: 'PANNOTAVBL',
        deducteeName: 'Unknown',
        amountPaid: 5000.00,
        tdsAmount: 1000.00,
        dateOfPayment: '01012026',
        sectionCode: '194C',
        deducteeTypeCode: FvuDeducteeTypeCode.nonCompany,
      );
      expect(noPan.pan, 'PANNOTAVBL');
      expect(noPan.hasPan, isFalse);
    });

    test('hasPan returns true for valid PAN', () {
      expect(record.hasPan, isTrue);
    });

    test('deducteeTypeCode values map correctly', () {
      expect(FvuDeducteeTypeCode.company.code, '1');
      expect(FvuDeducteeTypeCode.nonCompany.code, '2');
    });

    test('toString includes key fields', () {
      final str = record.toString();
      expect(str, contains('ABCDE1234F'));
      expect(str, contains('194J'));
    });
  });
}
