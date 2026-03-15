import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/reconciliation/ais_entry.dart';
import 'package:ca_app/features/filing/domain/models/reconciliation/form_26as_entry.dart';
import 'package:ca_app/features/filing/domain/services/reconciliation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseForm = Itr1FormData.empty().copyWith(
    salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 500000),
    otherSourceIncome: OtherSourceIncome.empty().copyWith(
      savingsAccountInterest: 10000,
      fixedDepositInterest: 5000,
      dividendIncome: 8000,
    ),
  );

  final now = DateTime(2025, 3, 15);

  group('ReconciliationEngine.reconcile26AS', () {
    test('returns matched result when salary TDS matches declared salary', () {
      final entries = [
        Form26ASEntry(
          deductorName: 'Employer A',
          deductorTan: 'TANA12345B',
          entryType: TdsEntryType.tdsSalary,
          grossAmount: 500000,
          tdsAmount: 25000,
          transactionDate: now,
        ),
      ];

      final results = ReconciliationEngine.reconcile26AS(entries, baseForm);

      expect(results, hasLength(1));
      expect(results.first.status, MatchStatus.matched);
      expect(results.first.discrepancy, 0.0);
      expect(results.first.source, contains('Salary'));
    });

    test('detects under-reported when declared salary < reported salary', () {
      final form = baseForm.copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 400000),
      );
      final entries = [
        Form26ASEntry(
          deductorName: 'Employer A',
          deductorTan: 'TANA12345B',
          entryType: TdsEntryType.tdsSalary,
          grossAmount: 500000,
          tdsAmount: 25000,
          transactionDate: now,
        ),
      ];

      final results = ReconciliationEngine.reconcile26AS(entries, form);

      expect(results.first.status, MatchStatus.underReported);
      expect(results.first.discrepancy, -100000);
    });

    test('aggregates multiple salary entries before comparing', () {
      final entries = [
        Form26ASEntry(
          deductorName: 'Employer A',
          deductorTan: 'TANA12345B',
          entryType: TdsEntryType.tdsSalary,
          grossAmount: 300000,
          tdsAmount: 15000,
          transactionDate: now,
        ),
        Form26ASEntry(
          deductorName: 'Employer B',
          deductorTan: 'TANB12345C',
          entryType: TdsEntryType.tdsSalary,
          grossAmount: 200000,
          tdsAmount: 10000,
          transactionDate: now,
        ),
      ];

      final results = ReconciliationEngine.reconcile26AS(entries, baseForm);

      expect(results, hasLength(1));
      expect(results.first.reportedAmount, 500000);
      expect(results.first.status, MatchStatus.matched);
    });

    test('reconciles non-salary TDS against other source income total', () {
      final entries = [
        Form26ASEntry(
          deductorName: 'Bank X',
          deductorTan: 'TANX12345D',
          entryType: TdsEntryType.tdsNonSalary,
          grossAmount: 23000, // total other source = 10000+5000+8000 = 23000
          tdsAmount: 2300,
          transactionDate: now,
        ),
      ];

      final results = ReconciliationEngine.reconcile26AS(entries, baseForm);

      expect(results, hasLength(1));
      expect(results.first.status, MatchStatus.matched);
      expect(results.first.source, contains('Non-Salary'));
    });

    test('returns empty list for empty entries', () {
      final results = ReconciliationEngine.reconcile26AS(
        <Form26ASEntry>[],
        baseForm,
      );

      expect(results, isEmpty);
    });
  });

  group('ReconciliationEngine.reconcileAIS', () {
    test('returns matched result when salary AIS matches declared', () {
      final entries = [
        AisEntry(
          category: AisCategory.salary,
          informationSource: 'Employer A',
          reportedAmount: 500000,
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results, hasLength(1));
      expect(results.first.status, MatchStatus.matched);
      expect(results.first.source, contains('Salary'));
    });

    test('detects discrepancy for interest category', () {
      final entries = [
        AisEntry(
          category: AisCategory.interest,
          informationSource: 'SBI',
          reportedAmount: 50000, // declared = 10000+5000 = 15000
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results, hasLength(1));
      expect(results.first.status, MatchStatus.underReported);
      expect(results.first.declaredAmount, 15000);
      expect(results.first.reportedAmount, 50000);
    });

    test('reconciles dividend category correctly', () {
      final entries = [
        AisEntry(
          category: AisCategory.dividend,
          informationSource: 'Mutual Fund Co',
          reportedAmount: 8000,
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results, hasLength(1));
      expect(results.first.status, MatchStatus.matched);
      expect(results.first.declaredAmount, 8000);
    });

    test('returns empty list for empty entries', () {
      final results = ReconciliationEngine.reconcileAIS(<AisEntry>[], baseForm);

      expect(results, isEmpty);
    });

    test('maps saleOfSecurities category to otherSourceIncome.total', () {
      final entries = [
        AisEntry(
          category: AisCategory.saleOfSecurities,
          informationSource: 'Broker X',
          reportedAmount: 23000, // same as total other source income
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results.first.status, MatchStatus.matched);
    });

    test('maps purchase category to otherSourceIncome.total', () {
      final entries = [
        AisEntry(
          category: AisCategory.purchase,
          informationSource: 'Broker Y',
          reportedAmount: 23000,
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results.first.status, MatchStatus.matched);
    });

    test('maps otherIncome category to otherSourceIncome.total', () {
      final entries = [
        AisEntry(
          category: AisCategory.otherIncome,
          informationSource: 'Platform Z',
          reportedAmount: 23000,
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results.first.status, MatchStatus.matched);
    });

    test('detects over-reported when declared > reported', () {
      final entries = [
        AisEntry(
          category: AisCategory.salary,
          informationSource: 'Employer',
          reportedAmount: 400000, // declared = 500000
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results.first.status, MatchStatus.overReported);
      expect(results.first.discrepancy, 100000.0);
    });

    test('detects missing when declared is 0 but reported > 0', () {
      final form = baseForm.copyWith(
        salaryIncome: SalaryIncome.empty().copyWith(grossSalary: 0),
      );
      final entries = [
        AisEntry(
          category: AisCategory.salary,
          informationSource: 'Employer',
          reportedAmount: 500000,
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, form);

      expect(results.first.status, MatchStatus.missing);
    });

    test('amounts within 1 rupee tolerance are matched', () {
      final entries = [
        AisEntry(
          category: AisCategory.salary,
          informationSource: 'Employer',
          reportedAmount: 500001.0, // within Rs 1 of declared 500000
        ),
      ];

      final results = ReconciliationEngine.reconcileAIS(entries, baseForm);

      expect(results.first.status, MatchStatus.matched);
    });
  });

  group('ReconciliationResult', () {
    test('copyWith creates new instance', () {
      const original = ReconciliationResult(
        source: 'Test',
        reportedAmount: 100000,
        declaredAmount: 100000,
        discrepancy: 0,
        status: MatchStatus.matched,
      );
      final updated = original.copyWith(discrepancy: -5000);

      expect(updated.discrepancy, -5000);
      expect(updated.source, original.source);
    });

    test('equality — same fields are equal', () {
      const a = ReconciliationResult(
        source: 'Test',
        reportedAmount: 100000,
        declaredAmount: 100000,
        discrepancy: 0,
        status: MatchStatus.matched,
      );
      const b = ReconciliationResult(
        source: 'Test',
        reportedAmount: 100000,
        declaredAmount: 100000,
        discrepancy: 0,
        status: MatchStatus.matched,
      );

      expect(a, equals(b));
    });
  });

  group('MatchStatus', () {
    test('labels are correct', () {
      expect(MatchStatus.matched.label, 'Matched');
      expect(MatchStatus.underReported.label, 'Under-Reported');
      expect(MatchStatus.overReported.label, 'Over-Reported');
      expect(MatchStatus.missing.label, 'Missing');
    });
  });
}
