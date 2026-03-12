import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductee_entry.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TdsAddress', () {
    TdsAddress createAddress({
      String line1 = '123 Main Street',
      String? line2,
      String city = 'Mumbai',
      String state = 'Maharashtra',
      String pincode = '400001',
    }) {
      return TdsAddress(
        line1: line1,
        line2: line2,
        city: city,
        state: state,
        pincode: pincode,
      );
    }

    test('creates with correct values', () {
      final address = createAddress(line2: 'Suite 200');
      expect(address.line1, '123 Main Street');
      expect(address.line2, 'Suite 200');
      expect(address.city, 'Mumbai');
      expect(address.state, 'Maharashtra');
      expect(address.pincode, '400001');
    });

    test('line2 defaults to null', () {
      final address = createAddress();
      expect(address.line2, isNull);
    });

    test('copyWith replaces specified fields', () {
      final address = createAddress();
      final updated = address.copyWith(city: 'Delhi', pincode: '110001');
      expect(updated.city, 'Delhi');
      expect(updated.pincode, '110001');
      expect(updated.line1, '123 Main Street');
    });

    test('equality → same values are equal', () {
      final a = createAddress();
      final b = createAddress();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality → different values are not equal', () {
      final a = createAddress(city: 'Mumbai');
      final b = createAddress(city: 'Delhi');
      expect(a, isNot(equals(b)));
    });
  });

  group('TdsReturnForm', () {
    TdsDeducteeEntry createEntry({
      String id = 'entry-1',
      double tdsDeducted = 5000,
      double tdsDeposited = 4000,
    }) {
      return TdsDeducteeEntry(
        id: id,
        deducteeName: 'Test Deductee',
        deducteePan: 'ABCDE1234F',
        deducteeType: DeducteeType.individual,
        section: '194C',
        dateOfPayment: DateTime(2025, 7, 15),
        dateOfDeduction: DateTime(2025, 7, 15),
        amountPaid: 100000,
        tdsDeducted: tdsDeducted,
        tdsDeposited: tdsDeposited,
      );
    }

    TdsChallan createChallan({String id = 'ch-1'}) {
      return TdsChallan(
        id: id,
        deductorId: 'ded-1',
        challanNumber: 'ITNS281-2025-0001',
        bsrCode: '0002390',
        section: '194C',
        deducteeCount: 1,
        tdsAmount: 5000,
        surcharge: 0,
        educationCess: 0,
        interest: 0,
        penalty: 0,
        totalAmount: 5000,
        paymentDate: '15 Jul 2025',
        month: 7,
        financialYear: '2025-26',
        status: 'Paid',
      );
    }

    TdsReturnForm createForm({
      String id = 'form-1',
      TdsFormType formType = TdsFormType.form26Q,
      TdsQuarter quarter = TdsQuarter.q1,
      List<TdsDeducteeEntry>? entries,
      List<TdsChallan>? challans,
      TdsReturnStatus status = TdsReturnStatus.pending,
      DateTime? filedDate,
      String? tokenNumber,
    }) {
      return TdsReturnForm(
        id: id,
        formType: formType,
        quarter: quarter,
        financialYear: '2025-26',
        deductorTan: 'MUMA12345B',
        deductorPan: 'ABCDE1234F',
        deductorName: 'Test Company',
        deductorAddress: const TdsAddress(
          line1: '123 Main St',
          city: 'Mumbai',
          state: 'Maharashtra',
          pincode: '400001',
        ),
        responsiblePerson: 'John Doe',
        entries: entries ?? [createEntry()],
        challans: challans ?? [createChallan()],
        status: status,
        filedDate: filedDate,
        tokenNumber: tokenNumber,
      );
    }

    test('creates with correct values', () {
      final form = createForm();
      expect(form.id, 'form-1');
      expect(form.formType, TdsFormType.form26Q);
      expect(form.quarter, TdsQuarter.q1);
      expect(form.financialYear, '2025-26');
      expect(form.deductorTan, 'MUMA12345B');
      expect(form.deductorPan, 'ABCDE1234F');
      expect(form.deductorName, 'Test Company');
      expect(form.responsiblePerson, 'John Doe');
      expect(form.status, TdsReturnStatus.pending);
      expect(form.filedDate, isNull);
      expect(form.tokenNumber, isNull);
    });

    test('copyWith replaces specified fields', () {
      final form = createForm();
      final updated = form.copyWith(
        status: TdsReturnStatus.filed,
        filedDate: DateTime(2025, 7, 31),
        tokenNumber: 'TKN-001',
      );
      expect(updated.status, TdsReturnStatus.filed);
      expect(updated.filedDate, DateTime(2025, 7, 31));
      expect(updated.tokenNumber, 'TKN-001');
      expect(updated.id, 'form-1');
    });

    test('equality is by id only', () {
      final a = createForm(id: 'same', status: TdsReturnStatus.pending);
      final b = createForm(id: 'same', status: TdsReturnStatus.filed);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different id → not equal', () {
      final a = createForm(id: 'id-1');
      final b = createForm(id: 'id-2');
      expect(a, isNot(equals(b)));
    });

    group('computed getters', () {
      test('totalTdsDeducted → sum of all entries', () {
        final form = createForm(
          entries: [
            createEntry(id: 'e1', tdsDeducted: 5000),
            createEntry(id: 'e2', tdsDeducted: 3000),
          ],
        );
        expect(form.totalTdsDeducted, 8000);
      });

      test('totalTdsDeposited → sum of all entries', () {
        final form = createForm(
          entries: [
            createEntry(id: 'e1', tdsDeposited: 4000),
            createEntry(id: 'e2', tdsDeposited: 2500),
          ],
        );
        expect(form.totalTdsDeposited, 6500);
      });

      test('shortfall → deducted minus deposited', () {
        final form = createForm(
          entries: [
            createEntry(
              id: 'e1',
              tdsDeducted: 5000,
              tdsDeposited: 4000,
            ),
          ],
        );
        expect(form.shortfall, 1000);
      });

      test('entryCount → number of entries', () {
        final form = createForm(
          entries: [
            createEntry(id: 'e1'),
            createEntry(id: 'e2'),
            createEntry(id: 'e3'),
          ],
        );
        expect(form.entryCount, 3);
      });

      test('empty entries → zero totals', () {
        final form = createForm(entries: []);
        expect(form.totalTdsDeducted, 0);
        expect(form.totalTdsDeposited, 0);
        expect(form.shortfall, 0);
        expect(form.entryCount, 0);
      });
    });
  });
}
