import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/audit/domain/models/form3cd_clause.dart';
import 'package:ca_app/features/audit/domain/services/form3cd_generation_service.dart';

void main() {
  group('Form3CDGenerationService', () {
    group('generateForm3CD', () {
      test('generates a form with clauses 1 through 44', () {
        const data = BusinessData(
          clientName: 'Test Pvt Ltd',
          pan: 'AAAPL1234C',
          assessmentYear: '2025-26',
          financialYear: 2025,
          businessNature: 'Manufacturing',
          accountingMethod: AccountingMethod.mercantile,
          totalTurnover: 50000000000, // 50 crore in paise
          relatedPartyPayments: [],
          msmePaymentsBeyond45Days: [],
          cashLoanReceipts: [],
          cashLoanRepayments: [],
          depreciationEntries: [],
          valuationMethod: InventoryValuationMethod.fifo,
        );

        final result = Form3CDGenerationService.generateForm3CD(data: data);

        expect(result.clauses.length, equals(44));
        for (int i = 1; i <= 44; i++) {
          expect(
            result.clauses.any((c) => c.clauseNumber == i),
            isTrue,
            reason: 'Clause $i should be present',
          );
        }
      });

      test('clause 13 reflects the accounting method (mercantile)', () {
        const data = BusinessData(
          clientName: 'ABC Ltd',
          pan: 'AAACL1234D',
          assessmentYear: '2025-26',
          financialYear: 2025,
          businessNature: 'Trading',
          accountingMethod: AccountingMethod.mercantile,
          totalTurnover: 10000000000,
          relatedPartyPayments: [],
          msmePaymentsBeyond45Days: [],
          cashLoanReceipts: [],
          cashLoanRepayments: [],
          depreciationEntries: [],
          valuationMethod: InventoryValuationMethod.fifo,
        );

        final result = Form3CDGenerationService.generateForm3CD(data: data);
        final clause13 = result.clauseByNumber(13);

        expect(clause13, isNotNull);
        expect(clause13!.response, contains('Mercantile'));
      });

      test(
        'clause 26 flags related party payments for disallowance under Sec 40A(2)',
        () {
          const data = BusinessData(
            clientName: 'XYZ Ltd',
            pan: 'AAAXL5678B',
            assessmentYear: '2025-26',
            financialYear: 2025,
            businessNature: 'Services',
            accountingMethod: AccountingMethod.mercantile,
            totalTurnover: 5000000000,
            relatedPartyPayments: [
              RelatedPartyPayment(
                partyName: 'Related Co Ltd',
                relationship: 'Subsidiary',
                amountPaidPaise: 200000000,
                fairMarketValuePaise: 150000000,
                excessPaymentPaise: 50000000,
              ),
            ],
            msmePaymentsBeyond45Days: [],
            cashLoanReceipts: [],
            cashLoanRepayments: [],
            depreciationEntries: [],
            valuationMethod: InventoryValuationMethod.fifo,
          );

          final result = Form3CDGenerationService.generateForm3CD(data: data);
          final clause26 = result.clauseByNumber(26);

          expect(clause26, isNotNull);
          expect(clause26!.hasDisclosures, isTrue);
          expect(clause26.disclosures, isNotEmpty);
        },
      );

      test('clause 36 flags MSME payments beyond 45 days under Sec 43B(h)', () {
        const data = BusinessData(
          clientName: 'PQR Ltd',
          pan: 'AAAPQ9012E',
          assessmentYear: '2025-26',
          financialYear: 2025,
          businessNature: 'Manufacturing',
          accountingMethod: AccountingMethod.mercantile,
          totalTurnover: 8000000000,
          relatedPartyPayments: [],
          msmePaymentsBeyond45Days: [
            MsmePayment(
              supplierName: 'Small Supplier',
              amountPaise: 100000000,
              dueDateExceededBy: 20,
            ),
          ],
          cashLoanReceipts: [],
          cashLoanRepayments: [],
          depreciationEntries: [],
          valuationMethod: InventoryValuationMethod.fifo,
        );

        final result = Form3CDGenerationService.generateForm3CD(data: data);
        final clause36 = result.clauseByNumber(36);

        expect(clause36, isNotNull);
        expect(clause36!.hasDisclosures, isTrue);
      });

      test('clause 40 flags cash loans > 20000 under Sec 269SS', () {
        final data = BusinessData(
          clientName: 'DEF Ltd',
          pan: 'AAADF3456F',
          assessmentYear: '2025-26',
          financialYear: 2025,
          businessNature: 'Finance',
          accountingMethod: AccountingMethod.mercantile,
          totalTurnover: 2000000000,
          relatedPartyPayments: const [],
          msmePaymentsBeyond45Days: const [],
          cashLoanReceipts: [
            CashLoanTransaction(
              partyName: 'Individual A',
              amountPaise: 2500000, // Rs 25,000 in paise
              transactionDate: DateTime(2024, 8, 15),
            ),
          ],
          cashLoanRepayments: const [],
          depreciationEntries: const [],
          valuationMethod: InventoryValuationMethod.fifo,
        );

        final result = Form3CDGenerationService.generateForm3CD(data: data);
        final clause40 = result.clauseByNumber(40);

        expect(clause40, isNotNull);
        expect(clause40!.hasDisclosures, isTrue);
      });

      test('clause 41 flags cash repayments > 20000 under Sec 269T', () {
        final data = BusinessData(
          clientName: 'GHI Ltd',
          pan: 'AAAGH7890G',
          assessmentYear: '2025-26',
          financialYear: 2025,
          businessNature: 'Finance',
          accountingMethod: AccountingMethod.mercantile,
          totalTurnover: 1500000000,
          relatedPartyPayments: const [],
          msmePaymentsBeyond45Days: const [],
          cashLoanReceipts: const [],
          cashLoanRepayments: [
            CashLoanTransaction(
              partyName: 'Creditor B',
              amountPaise: 3000000, // Rs 30,000 in paise
              transactionDate: DateTime(2024, 12, 10),
            ),
          ],
          depreciationEntries: const [],
          valuationMethod: InventoryValuationMethod.fifo,
        );

        final result = Form3CDGenerationService.generateForm3CD(data: data);
        final clause41 = result.clauseByNumber(41);

        expect(clause41, isNotNull);
        expect(clause41!.hasDisclosures, isTrue);
      });

      test('no related party payments means clause 26 has no disclosures', () {
        const data = BusinessData(
          clientName: 'Clean Ltd',
          pan: 'AAACL9999H',
          assessmentYear: '2025-26',
          financialYear: 2025,
          businessNature: 'IT Services',
          accountingMethod: AccountingMethod.mercantile,
          totalTurnover: 3000000000,
          relatedPartyPayments: [],
          msmePaymentsBeyond45Days: [],
          cashLoanReceipts: [],
          cashLoanRepayments: [],
          depreciationEntries: [],
          valuationMethod: InventoryValuationMethod.fifo,
        );

        final result = Form3CDGenerationService.generateForm3CD(data: data);
        final clause26 = result.clauseByNumber(26);

        expect(clause26!.hasDisclosures, isFalse);
      });

      test('Form3CD is immutable — copyWith preserves other fields', () {
        const data = BusinessData(
          clientName: 'Test Ltd',
          pan: 'AAATL1111I',
          assessmentYear: '2025-26',
          financialYear: 2025,
          businessNature: 'Trading',
          accountingMethod: AccountingMethod.mercantile,
          totalTurnover: 1000000000,
          relatedPartyPayments: [],
          msmePaymentsBeyond45Days: [],
          cashLoanReceipts: [],
          cashLoanRepayments: [],
          depreciationEntries: [],
          valuationMethod: InventoryValuationMethod.fifo,
        );

        final original = Form3CDGenerationService.generateForm3CD(data: data);
        final updated = original.copyWith(assessmentYear: '2026-27');

        expect(updated.assessmentYear, equals('2026-27'));
        expect(original.assessmentYear, equals('2025-26'));
        expect(updated.clauses.length, equals(44));
      });
    });

    group('Form3CDClause model', () {
      test('hasDisclosures is true when disclosures list is non-empty', () {
        const clause = Form3CDClause(
          clauseNumber: 26,
          description: 'Related party payments',
          response: 'Yes',
          disclosures: ['Payment to Related Co: Rs 50,000 excess'],
        );

        expect(clause.hasDisclosures, isTrue);
      });

      test('hasDisclosures is false when disclosures list is empty', () {
        const clause = Form3CDClause(
          clauseNumber: 26,
          description: 'Related party payments',
          response: 'No',
          disclosures: [],
        );

        expect(clause.hasDisclosures, isFalse);
      });

      test('equality and hashCode are value-based', () {
        const a = Form3CDClause(
          clauseNumber: 13,
          description: 'Accounting method',
          response: 'Mercantile',
          disclosures: [],
        );
        const b = Form3CDClause(
          clauseNumber: 13,
          description: 'Accounting method',
          response: 'Mercantile',
          disclosures: [],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
