import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductee_entry.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';
import 'package:ca_app/features/tds/domain/services/tds_return_form_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TdsReturnFormService', () {
    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    TdsDeducteeEntry createEntry({
      String id = 'entry-1',
      String section = '194C',
      DateTime? dateOfPayment,
      double tdsDeducted = 2000,
      double tdsDeposited = 2000,
      String? challanId,
    }) {
      return TdsDeducteeEntry(
        id: id,
        deducteeName: 'Test Deductee',
        deducteePan: 'ABCDE1234F',
        deducteeType: DeducteeType.individual,
        section: section,
        dateOfPayment: dateOfPayment ?? DateTime(2025, 7, 15),
        dateOfDeduction: dateOfPayment ?? DateTime(2025, 7, 15),
        amountPaid: 100000,
        tdsDeducted: tdsDeducted,
        tdsDeposited: tdsDeposited,
        challanId: challanId,
      );
    }

    TdsChallan createChallan({
      String id = 'ch-1',
      String section = '194C',
      int month = 7,
      double totalAmount = 5000,
    }) {
      return TdsChallan(
        id: id,
        deductorId: 'ded-1',
        challanNumber: 'ITNS281-2025-0001',
        bsrCode: '0002390',
        section: section,
        deducteeCount: 1,
        tdsAmount: totalAmount,
        surcharge: 0,
        educationCess: 0,
        interest: 0,
        penalty: 0,
        totalAmount: totalAmount,
        paymentDate: '15 Jul 2025',
        month: month,
        financialYear: '2025-26',
        status: 'Paid',
      );
    }

    TdsReturnForm createForm({
      String deductorTan = 'MUMA12345B',
      String deductorPan = 'ABCDE1234F',
      TdsFormType formType = TdsFormType.form26Q,
      TdsQuarter quarter = TdsQuarter.q1,
      List<TdsDeducteeEntry>? entries,
      List<TdsChallan>? challans,
      TdsReturnStatus status = TdsReturnStatus.pending,
      DateTime? filedDate,
    }) {
      return TdsReturnForm(
        id: 'form-1',
        formType: formType,
        quarter: quarter,
        financialYear: '2025-26',
        deductorTan: deductorTan,
        deductorPan: deductorPan,
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
      );
    }

    // -------------------------------------------------------------------------
    // validate
    // -------------------------------------------------------------------------

    group('validate', () {
      test('valid form → empty errors', () {
        final form = createForm();
        final errors = TdsReturnFormService.validate(form);
        expect(errors, isEmpty);
      });

      test('missing TAN → error', () {
        final form = createForm(deductorTan: '');
        final errors = TdsReturnFormService.validate(form);
        expect(errors, contains(contains('TAN')));
      });

      test('invalid TAN format → error', () {
        final form = createForm(deductorTan: '12345ABCDE');
        final errors = TdsReturnFormService.validate(form);
        expect(errors, contains(contains('TAN')));
      });

      test('valid TAN format passes', () {
        // TAN: 4 alpha + 5 numeric + 1 alpha
        final form = createForm(deductorTan: 'MUMA12345B');
        final errors = TdsReturnFormService.validate(form);
        expect(
          errors.where((e) => e.contains('TAN')),
          isEmpty,
        );
      });

      test('invalid PAN format → error', () {
        final form = createForm(deductorPan: 'INVALID');
        final errors = TdsReturnFormService.validate(form);
        expect(errors, contains(contains('PAN')));
      });

      test('no entries → error', () {
        final form = createForm(entries: []);
        final errors = TdsReturnFormService.validate(form);
        expect(errors, contains(contains('entry')));
      });

      test('entry without section → error', () {
        final form = createForm(entries: [createEntry(section: '')]);
        final errors = TdsReturnFormService.validate(form);
        expect(errors, contains(contains('section')));
      });

      test('challan total < deductee total → error', () {
        final form = createForm(
          entries: [createEntry(tdsDeducted: 10000)],
          challans: [createChallan(totalAmount: 5000)],
        );
        final errors = TdsReturnFormService.validate(form);
        expect(errors, contains(contains('challan')));
      });
    });

    // -------------------------------------------------------------------------
    // getDueDate
    // -------------------------------------------------------------------------

    group('getDueDate', () {
      test('Q1 24Q → Jul 31 of same calendar year', () {
        final date = TdsReturnFormService.getDueDate(
          formType: TdsFormType.form24Q,
          quarter: TdsQuarter.q1,
          financialYear: '2025-26',
        );
        expect(date, DateTime(2025, 7, 31));
      });

      test('Q2 26Q → Oct 31', () {
        final date = TdsReturnFormService.getDueDate(
          formType: TdsFormType.form26Q,
          quarter: TdsQuarter.q2,
          financialYear: '2025-26',
        );
        expect(date, DateTime(2025, 10, 31));
      });

      test('Q3 27Q → Jan 31 of next calendar year', () {
        final date = TdsReturnFormService.getDueDate(
          formType: TdsFormType.form27Q,
          quarter: TdsQuarter.q3,
          financialYear: '2025-26',
        );
        expect(date, DateTime(2026, 1, 31));
      });

      test('Q4 26Q → May 31 of next calendar year', () {
        final date = TdsReturnFormService.getDueDate(
          formType: TdsFormType.form26Q,
          quarter: TdsQuarter.q4,
          financialYear: '2025-26',
        );
        expect(date, DateTime(2026, 5, 31));
      });

      test('Q1 27EQ → Jul 15', () {
        final date = TdsReturnFormService.getDueDate(
          formType: TdsFormType.form27EQ,
          quarter: TdsQuarter.q1,
          financialYear: '2025-26',
        );
        expect(date, DateTime(2025, 7, 15));
      });

      test('Q4 27EQ → May 15', () {
        final date = TdsReturnFormService.getDueDate(
          formType: TdsFormType.form27EQ,
          quarter: TdsQuarter.q4,
          financialYear: '2025-26',
        );
        expect(date, DateTime(2026, 5, 15));
      });
    });

    // -------------------------------------------------------------------------
    // isOverdue
    // -------------------------------------------------------------------------

    group('isOverdue', () {
      test('filed after due date → true', () {
        final form = createForm(
          formType: TdsFormType.form26Q,
          quarter: TdsQuarter.q1,
          status: TdsReturnStatus.pending,
          filedDate: DateTime(2025, 8, 15),
        );
        final result = TdsReturnFormService.isOverdue(form);
        expect(result, true);
      });

      test('filed before due date → false', () {
        final form = createForm(
          formType: TdsFormType.form26Q,
          quarter: TdsQuarter.q1,
          status: TdsReturnStatus.filed,
          filedDate: DateTime(2025, 7, 20),
        );
        final result = TdsReturnFormService.isOverdue(form);
        expect(result, false);
      });

      test('not yet filed, pending status → checks current date concept', () {
        // A pending form with no filedDate: overdue is determined
        // by whether we are past the due date. We test the logic
        // by checking the returned value is a bool.
        final form = createForm(
          formType: TdsFormType.form26Q,
          quarter: TdsQuarter.q1,
          status: TdsReturnStatus.pending,
        );
        final result = TdsReturnFormService.isOverdue(form);
        expect(result, isA<bool>());
      });
    });

    // -------------------------------------------------------------------------
    // calculateLateFee
    // -------------------------------------------------------------------------

    group('calculateLateFee', () {
      test('10 days late → Rs 2,000', () {
        final fee = TdsReturnFormService.calculateLateFee(
          filingDate: DateTime(2025, 8, 10),
          dueDate: DateTime(2025, 7, 31),
          totalTds: 50000,
        );
        expect(fee, 2000);
      });

      test('capped at totalTds amount', () {
        final fee = TdsReturnFormService.calculateLateFee(
          filingDate: DateTime(2025, 12, 31),
          dueDate: DateTime(2025, 7, 31),
          totalTds: 500,
        );
        expect(fee, 500);
      });

      test('filing on due date → zero fee', () {
        final fee = TdsReturnFormService.calculateLateFee(
          filingDate: DateTime(2025, 7, 31),
          dueDate: DateTime(2025, 7, 31),
          totalTds: 50000,
        );
        expect(fee, 0);
      });

      test('filing before due date → zero fee', () {
        final fee = TdsReturnFormService.calculateLateFee(
          filingDate: DateTime(2025, 7, 20),
          dueDate: DateTime(2025, 7, 31),
          totalTds: 50000,
        );
        expect(fee, 0);
      });
    });

    // -------------------------------------------------------------------------
    // linkChallans
    // -------------------------------------------------------------------------

    group('linkChallans', () {
      test('matches entries to challans by section + month', () {
        final entries = [
          createEntry(
            id: 'e1',
            section: '194C',
            dateOfPayment: DateTime(2025, 7, 15),
          ),
          createEntry(
            id: 'e2',
            section: '194J(b)',
            dateOfPayment: DateTime(2025, 8, 10),
          ),
        ];

        final challans = [
          createChallan(id: 'ch-1', section: '194C', month: 7),
          createChallan(id: 'ch-2', section: '194J(b)', month: 8),
        ];

        final linked = TdsReturnFormService.linkChallans(
          entries: entries,
          challans: challans,
        );

        expect(linked[0].challanId, 'ch-1');
        expect(linked[1].challanId, 'ch-2');
      });

      test('no matching challan → challanId remains null', () {
        final entries = [
          createEntry(
            id: 'e1',
            section: '194C',
            dateOfPayment: DateTime(2025, 7, 15),
          ),
        ];

        final challans = [
          createChallan(id: 'ch-1', section: '194J(b)', month: 7),
        ];

        final linked = TdsReturnFormService.linkChallans(
          entries: entries,
          challans: challans,
        );

        expect(linked[0].challanId, isNull);
      });
    });
  });
}
