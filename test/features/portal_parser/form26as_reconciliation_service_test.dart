import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_parser/models/form26as_data.dart';
import 'package:ca_app/features/portal_parser/models/tds_entry_26as.dart';
import 'package:ca_app/features/portal_parser/services/form26as_reconciliation_service.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductee_entry.dart';
import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';

void main() {
  group('Form26AsReconciliationService', () {
    late Form26AsReconciliationService service;

    final tdsEntry = TdsEntry26As(
      deductorTan: 'AAATA1234X',
      deductorName: 'ABC Company Ltd',
      section: '192',
      amount: 50000000, // 500000 rupees in paise
      tdsDeducted: 5000000, // 50000 rupees in paise
      dateOfDeduction: DateTime(2024, 3, 31),
      status: BookingStatus.booked,
    );

    final form26as = Form26AsData(
      pan: 'ABCDE1234F',
      assessmentYear: '2024-25',
      tdsEntries: [tdsEntry],
      tcsTcsEntries: const [],
      advanceTaxEntries: const [],
      selfAssessmentEntries: const [],
      refundEntries: const [],
      totalTdsCredited: 5000000,
      totalTcsCredited: 0,
    );

    final matchingReturn = TdsReturn(
      id: 'r1',
      deductorId: 'd1',
      tan: 'AAATA1234X',
      formType: TdsFormType.form24Q,
      quarter: TdsQuarter.q4,
      financialYear: '2023-24',
      status: TdsReturnStatus.filed,
      totalDeductions: 500000,
      totalTaxDeducted: 50000,
      totalDeposited: 50000,
    );

    setUp(() {
      service = Form26AsReconciliationService.instance;
    });

    // --------------- reconcile ---------------

    group('reconcile', () {
      test('returns Form26AsReconciliationResult', () {
        final result = service.reconcile(form26as, [matchingReturn]);
        expect(result, isA<Form26AsReconciliationResult>());
      });

      test('result contains matched entries when TAN matches', () {
        final result = service.reconcile(form26as, [matchingReturn]);
        expect(result.matchedEntries, hasLength(1));
      });

      test('result contains unmatched entries when no filed return for TAN', () {
        final result = service.reconcile(form26as, []);
        expect(result.unmatchedEntries, hasLength(1));
      });

      test('totalCreditedPaise equals form26as totalTdsCredited', () {
        final result = service.reconcile(form26as, [matchingReturn]);
        expect(result.totalCreditedPaise, equals(5000000));
      });

      test('totalMatchedPaise equals sum of matched tdsDeducted', () {
        final result = service.reconcile(form26as, [matchingReturn]);
        expect(result.totalMatchedPaise, equals(5000000));
      });
    });

    // --------------- findMismatches ---------------

    group('findMismatches', () {
      test('returns empty list when deductee entry matches form 26AS', () {
        final deducteeEntry = TdsDeducteeEntry(
          id: 'e1',
          deducteeName: 'John Doe',
          deducteePan: 'ABCDE1234F',
          deducteeType: DeducteeType.individual,
          section: '192',
          dateOfPayment: DateTime(2024, 3, 31),
          dateOfDeduction: DateTime(2024, 3, 31),
          amountPaid: 500000,
          tdsDeducted: 50000,
          tdsDeposited: 50000,
        );
        final mismatches = service.findMismatches(form26as, [deducteeEntry]);
        expect(mismatches, isEmpty);
      });

      test('returns mismatch when TDS amounts differ', () {
        final deducteeEntry = TdsDeducteeEntry(
          id: 'e2',
          deducteeName: 'John Doe',
          deducteePan: 'ABCDE1234F',
          deducteeType: DeducteeType.individual,
          section: '192',
          dateOfPayment: DateTime(2024, 3, 31),
          dateOfDeduction: DateTime(2024, 3, 31),
          amountPaid: 500000,
          tdsDeducted: 40000, // mismatch: 26AS says 50000
          tdsDeposited: 40000,
        );
        final mismatches = service.findMismatches(form26as, [deducteeEntry]);
        expect(mismatches, hasLength(1));
        expect(mismatches.first.mismatchType, equals(MismatchType.amountDifference));
      });

      test('mismatch contains form26asPaise and booksPaise', () {
        final deducteeEntry = TdsDeducteeEntry(
          id: 'e3',
          deducteeName: 'John Doe',
          deducteePan: 'ABCDE1234F',
          deducteeType: DeducteeType.individual,
          section: '192',
          dateOfPayment: DateTime(2024, 3, 31),
          dateOfDeduction: DateTime(2024, 3, 31),
          amountPaid: 500000,
          tdsDeducted: 40000,
          tdsDeposited: 40000,
        );
        final mismatches = service.findMismatches(form26as, [deducteeEntry]);
        expect(mismatches.first.form26asPaise, equals(5000000));
        expect(mismatches.first.booksPaise, equals(4000000));
      });
    });

    // --------------- computeReconciliationSummary ---------------

    group('computeReconciliationSummary', () {
      test('returns ReconciliationSummary', () {
        final summary = service.computeReconciliationSummary(form26as);
        expect(summary, isA<ReconciliationSummary>());
      });

      test('totalEntries equals number of TDS entries', () {
        final summary = service.computeReconciliationSummary(form26as);
        expect(summary.totalEntries, equals(1));
      });

      test('totalTdsCreditedPaise matches form26as totalTdsCredited', () {
        final summary = service.computeReconciliationSummary(form26as);
        expect(summary.totalTdsCreditedPaise, equals(5000000));
      });

      test('bookedEntries counts entries with booked status', () {
        final summary = service.computeReconciliationSummary(form26as);
        expect(summary.bookedEntries, equals(1));
      });

      test('unmatchedEntries counts entries with unmatched status', () {
        final unmatchedEntry = TdsEntry26As(
          deductorTan: 'BBBBB1234X',
          deductorName: 'XYZ Ltd',
          section: '194C',
          amount: 10000000,
          tdsDeducted: 200000,
          dateOfDeduction: DateTime(2023, 9, 15),
          status: BookingStatus.unmatched,
        );
        final data = form26as.copyWith(
          tdsEntries: [tdsEntry, unmatchedEntry],
          totalTdsCredited: 5200000,
        );
        final summary = service.computeReconciliationSummary(data);
        expect(summary.unmatchedEntries, equals(1));
      });
    });

    // --------------- Model immutability ---------------

    group('Form26AsReconciliationResult model', () {
      test('copyWith creates new instance', () {
        final result = service.reconcile(form26as, [matchingReturn]);
        final updated = result.copyWith(totalCreditedPaise: 9999999);
        expect(updated.totalCreditedPaise, equals(9999999));
        expect(result.totalCreditedPaise, equals(5000000));
      });
    });

    group('TdsMismatch model', () {
      test('equality based on deductorTan and section', () {
        const a = TdsMismatch(
          deductorTan: 'AAATA1234X',
          section: '192',
          mismatchType: MismatchType.amountDifference,
          form26asPaise: 5000000,
          booksPaise: 4000000,
        );
        const b = TdsMismatch(
          deductorTan: 'AAATA1234X',
          section: '192',
          mismatchType: MismatchType.amountDifference,
          form26asPaise: 5000000,
          booksPaise: 4000000,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
