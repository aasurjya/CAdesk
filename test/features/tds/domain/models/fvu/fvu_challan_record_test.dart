import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_challan_record.dart';

void main() {
  group('FvuChallanRecord', () {
    const record = FvuChallanRecord(
      bsrCode: '0002390',
      challanTenderDate: '07032026',
      challanSerialNumber: '0000000234',
      totalTaxDeposited: 25000.50,
      deducteeCount: 5,
      sectionCode: '194C',
    );

    test('creates immutable instance with correct values', () {
      expect(record.bsrCode, '0002390');
      expect(record.challanTenderDate, '07032026');
      expect(record.challanSerialNumber, '0000000234');
      expect(record.totalTaxDeposited, 25000.50);
      expect(record.deducteeCount, 5);
      expect(record.sectionCode, '194C');
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = record.copyWith(deducteeCount: 8, sectionCode: '194J');
      expect(updated.deducteeCount, 8);
      expect(updated.sectionCode, '194J');
      expect(updated.bsrCode, record.bsrCode);
    });

    test('equality is value-based', () {
      const same = FvuChallanRecord(
        bsrCode: '0002390',
        challanTenderDate: '07032026',
        challanSerialNumber: '0000000234',
        totalTaxDeposited: 25000.50,
        deducteeCount: 5,
        sectionCode: '194C',
      );
      expect(record, equals(same));
      expect(record.hashCode, equals(same.hashCode));
    });

    test('inequality when fields differ', () {
      final different = record.copyWith(bsrCode: '9999999');
      expect(record, isNot(equals(different)));
    });

    test('toString includes key fields', () {
      final str = record.toString();
      expect(str, contains('0002390'));
      expect(str, contains('194C'));
    });
  });
}
