import 'package:ca_app/features/tds/domain/models/tds_deductee_entry.dart';
import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TdsDeducteeEntry', () {
    TdsDeducteeEntry createEntry({
      String id = 'entry-1',
      String deducteeName = 'ABC Contractors',
      String deducteePan = 'ABCDE1234F',
      DeducteeType deducteeType = DeducteeType.company,
      String section = '194C',
      DateTime? dateOfPayment,
      DateTime? dateOfDeduction,
      double amountPaid = 100000,
      double tdsDeducted = 2000,
      double tdsDeposited = 2000,
      String? challanId,
      String? certificateNumber,
      String? remarks,
    }) {
      return TdsDeducteeEntry(
        id: id,
        deducteeName: deducteeName,
        deducteePan: deducteePan,
        deducteeType: deducteeType,
        section: section,
        dateOfPayment: dateOfPayment ?? DateTime(2025, 7, 15),
        dateOfDeduction: dateOfDeduction ?? DateTime(2025, 7, 15),
        amountPaid: amountPaid,
        tdsDeducted: tdsDeducted,
        tdsDeposited: tdsDeposited,
        challanId: challanId,
        certificateNumber: certificateNumber,
        remarks: remarks,
      );
    }

    test('creates with correct values', () {
      final entry = createEntry();
      expect(entry.id, 'entry-1');
      expect(entry.deducteeName, 'ABC Contractors');
      expect(entry.deducteePan, 'ABCDE1234F');
      expect(entry.deducteeType, DeducteeType.company);
      expect(entry.section, '194C');
      expect(entry.amountPaid, 100000);
      expect(entry.tdsDeducted, 2000);
      expect(entry.tdsDeposited, 2000);
      expect(entry.challanId, isNull);
      expect(entry.certificateNumber, isNull);
      expect(entry.remarks, isNull);
    });

    test('copyWith replaces specified fields', () {
      final entry = createEntry();
      final updated = entry.copyWith(
        deducteeName: 'XYZ Ltd',
        tdsDeducted: 5000,
        challanId: 'ch-1',
      );
      expect(updated.deducteeName, 'XYZ Ltd');
      expect(updated.tdsDeducted, 5000);
      expect(updated.challanId, 'ch-1');
      // unchanged
      expect(updated.id, 'entry-1');
      expect(updated.section, '194C');
    });

    test('copyWith with no arguments returns equal object', () {
      final entry = createEntry();
      expect(entry.copyWith(), equals(entry));
    });

    test('equality is by id only', () {
      final a = createEntry(id: 'same-id', deducteeName: 'A');
      final b = createEntry(id: 'same-id', deducteeName: 'B');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different id → not equal', () {
      final a = createEntry(id: 'id-1');
      final b = createEntry(id: 'id-2');
      expect(a, isNot(equals(b)));
    });
  });
}
