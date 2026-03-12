import 'package:ca_app/features/tds/domain/models/form16a_data.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared test fixtures
  // ---------------------------------------------------------------------------

  final testAddress = TdsAddress(
    line1: '456 Park Street',
    city: 'Delhi',
    state: 'Delhi',
    pincode: '110001',
  );

  Form16ATransaction makeTransaction({
    double amountPaid = 100000,
    double tdsDeducted = 10000,
    double tdsDeposited = 10000,
  }) {
    return Form16ATransaction(
      dateOfPayment: DateTime(2025, 6, 15),
      dateOfDeduction: DateTime(2025, 6, 15),
      amountPaid: amountPaid,
      tdsDeducted: tdsDeducted,
      tdsDeposited: tdsDeposited,
      challanNumber: 'CH001',
      bsrCode: '0002390',
      dateOfDeposit: DateTime(2025, 7, 7),
    );
  }

  // ---------------------------------------------------------------------------
  // Form16ATransaction
  // ---------------------------------------------------------------------------

  group('Form16ATransaction →', () {
    test('creates with required fields', () {
      final txn = makeTransaction();
      expect(txn.amountPaid, 100000);
      expect(txn.tdsDeducted, 10000);
      expect(txn.tdsDeposited, 10000);
      expect(txn.challanNumber, 'CH001');
      expect(txn.bsrCode, '0002390');
    });

    test('copyWith replaces specified fields only', () {
      final original = makeTransaction();
      final updated = original.copyWith(amountPaid: 200000);
      expect(updated.amountPaid, 200000);
      expect(updated.tdsDeducted, original.tdsDeducted);
      expect(updated.challanNumber, original.challanNumber);
    });

    test('equality compares all fields', () {
      final a = makeTransaction();
      final b = makeTransaction();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when fields differ', () {
      final a = makeTransaction(amountPaid: 100000);
      final b = makeTransaction(amountPaid: 200000);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // Form16AData
  // ---------------------------------------------------------------------------

  group('Form16AData →', () {
    Form16AData makeForm16AData({
      String certificateNumber = 'CERT16A-001',
      List<Form16ATransaction>? transactions,
    }) {
      return Form16AData(
        certificateNumber: certificateNumber,
        deductorTan: 'DELH67890B',
        deductorPan: 'ABCDE1234F',
        deductorName: 'XYZ Services Ltd',
        deductorAddress: testAddress,
        deducteePan: 'PQRST9876Z',
        deducteeName: 'Amit Verma',
        deducteeAddress: testAddress,
        assessmentYear: '2026-27',
        quarter: TdsQuarter.q1,
        section: '194J',
        transactions: transactions ?? [makeTransaction(), makeTransaction()],
      );
    }

    test('creates with all required fields', () {
      final form = makeForm16AData();
      expect(form.certificateNumber, 'CERT16A-001');
      expect(form.deductorTan, 'DELH67890B');
      expect(form.section, '194J');
      expect(form.quarter, TdsQuarter.q1);
      expect(form.transactions.length, 2);
    });

    test('totalAmountPaid sums all transactions', () {
      final form = makeForm16AData(
        transactions: [
          makeTransaction(amountPaid: 100000),
          makeTransaction(amountPaid: 150000),
          makeTransaction(amountPaid: 200000),
        ],
      );
      expect(form.totalAmountPaid, 450000);
    });

    test('totalTdsDeducted sums all transactions', () {
      final form = makeForm16AData(
        transactions: [
          makeTransaction(tdsDeducted: 10000),
          makeTransaction(tdsDeducted: 15000),
        ],
      );
      expect(form.totalTdsDeducted, 25000);
    });

    test('totalTdsDeposited sums all transactions', () {
      final form = makeForm16AData(
        transactions: [
          makeTransaction(tdsDeposited: 10000),
          makeTransaction(tdsDeposited: 12000),
        ],
      );
      expect(form.totalTdsDeposited, 22000);
    });

    test('empty transactions gives zero totals', () {
      final form = makeForm16AData(transactions: const []);
      expect(form.totalAmountPaid, 0);
      expect(form.totalTdsDeducted, 0);
      expect(form.totalTdsDeposited, 0);
    });

    test('equality by certificateNumber', () {
      final a = makeForm16AData(certificateNumber: 'CERT16A-001');
      final b = makeForm16AData(certificateNumber: 'CERT16A-001');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when certificateNumber differs', () {
      final a = makeForm16AData(certificateNumber: 'CERT16A-001');
      final b = makeForm16AData(certificateNumber: 'CERT16A-002');
      expect(a, isNot(equals(b)));
    });

    test('copyWith replaces specified fields only', () {
      final original = makeForm16AData();
      final updated = original.copyWith(section: '194C');
      expect(updated.section, '194C');
      expect(updated.certificateNumber, original.certificateNumber);
      expect(updated.deductorTan, original.deductorTan);
    });
  });
}
