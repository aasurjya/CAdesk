import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/reconciliation/domain/models/bank_recon_item.dart';
import 'package:ca_app/features/reconciliation/domain/models/bank_reconciliation.dart';
import 'package:ca_app/features/reconciliation/domain/services/bank_reconciliation_service.dart';

void main() {
  final service = BankReconciliationService.instance;

  // Convenience helpers
  BankTransaction bankTx({
    required String id,
    required DateTime date,
    required int amount,
    required TxType type,
    String description = '',
  }) => BankTransaction(
        id: id,
        date: date,
        amount: amount,
        type: type,
        description: description,
      );

  BookEntry bookEntry({
    required String id,
    required DateTime date,
    required int amount,
    required TxType type,
    String description = '',
  }) => BookEntry(
        id: id,
        date: date,
        amount: amount,
        type: type,
        description: description,
      );

  group('BankReconciliationService', () {
    // -----------------------------------------------------------------------
    // matchTransactions
    // -----------------------------------------------------------------------
    group('matchTransactions', () {
      test('→ matched when date and amount are identical', () {
        final date = DateTime(2025, 4, 10);
        final bank = bankTx(id: 'B1', date: date, amount: 100000, type: TxType.credit);
        final books = [
          bookEntry(id: 'K1', date: date, amount: 100000, type: TxType.credit),
        ];
        final item = service.matchTransactions(bank, books);
        expect(item.status, ReconItemStatus.matched);
        expect(item.transactionId, 'B1');
      });

      test('→ matched when date is within ±3 days', () {
        final bankDate = DateTime(2025, 4, 10);
        final bookDate = DateTime(2025, 4, 12); // +2 days
        final bank = bankTx(id: 'B2', date: bankDate, amount: 50000, type: TxType.debit);
        final books = [
          bookEntry(id: 'K2', date: bookDate, amount: 50000, type: TxType.debit),
        ];
        final item = service.matchTransactions(bank, books);
        expect(item.status, ReconItemStatus.matched);
      });

      test('→ unmatchedInBank when no book entry within ±3 days', () {
        final bankDate = DateTime(2025, 4, 10);
        final bookDate = DateTime(2025, 4, 20); // 10 days away
        final bank = bankTx(id: 'B3', date: bankDate, amount: 50000, type: TxType.debit);
        final books = [
          bookEntry(id: 'K3', date: bookDate, amount: 50000, type: TxType.debit),
        ];
        final item = service.matchTransactions(bank, books);
        expect(item.status, ReconItemStatus.unmatchedInBank);
      });

      test('→ unmatchedInBank when amount differs by more than ₹1 (100 paise)', () {
        final date = DateTime(2025, 4, 10);
        final bank = bankTx(id: 'B4', date: date, amount: 100000, type: TxType.credit);
        final books = [
          bookEntry(id: 'K4', date: date, amount: 100200, type: TxType.credit), // ₹2 diff
        ];
        final item = service.matchTransactions(bank, books);
        expect(item.status, ReconItemStatus.unmatchedInBank);
      });

      test('→ matched when amount differs by exactly ₹1 (100 paise) — rounding', () {
        final date = DateTime(2025, 4, 10);
        final bank = bankTx(id: 'B5', date: date, amount: 100000, type: TxType.credit);
        final books = [
          bookEntry(id: 'K5', date: date, amount: 100100, type: TxType.credit), // ₹1 diff
        ];
        final item = service.matchTransactions(bank, books);
        expect(item.status, ReconItemStatus.matched);
      });

      test('→ unmatchedInBank when Dr/Cr type differs', () {
        final date = DateTime(2025, 4, 10);
        final bank = bankTx(id: 'B6', date: date, amount: 100000, type: TxType.credit);
        final books = [
          bookEntry(id: 'K6', date: date, amount: 100000, type: TxType.debit),
        ];
        final item = service.matchTransactions(bank, books);
        expect(item.status, ReconItemStatus.unmatchedInBank);
      });

      test('→ unmatchedInBank when books list is empty', () {
        final bank = bankTx(
          id: 'B7',
          date: DateTime(2025, 4, 1),
          amount: 5000,
          type: TxType.credit,
        );
        final item = service.matchTransactions(bank, []);
        expect(item.status, ReconItemStatus.unmatchedInBank);
      });
    });

    // -----------------------------------------------------------------------
    // reconcile
    // -----------------------------------------------------------------------
    group('reconcile', () {
      test('→ isBalanced true when bank and book balances match', () {
        final date = DateTime(2025, 4, 5);
        final bankStmt = [
          bankTx(id: 'B1', date: date, amount: 100000, type: TxType.credit),
          bankTx(id: 'B2', date: date, amount: 50000, type: TxType.debit),
        ];
        final bookEntries = [
          bookEntry(id: 'K1', date: date, amount: 100000, type: TxType.credit),
          bookEntry(id: 'K2', date: date, amount: 50000, type: TxType.debit),
        ];
        final recon = service.reconcile(
          bankStatement: bankStmt,
          bookEntries: bookEntries,
          period: 'Apr 2025',
          accountNumber: '****1234',
          bankName: 'HDFC Bank',
          bankBalance: 50000,
          bookBalance: 50000,
        );
        expect(recon.isBalanced, isTrue);
        expect(recon.period, 'Apr 2025');
        expect(recon.bankName, 'HDFC Bank');
      });

      test('→ isBalanced false when balances differ', () {
        final recon = service.reconcile(
          bankStatement: [],
          bookEntries: [],
          period: 'Apr 2025',
          accountNumber: '****5678',
          bankName: 'SBI',
          bankBalance: 100000,
          bookBalance: 90000,
        );
        expect(recon.isBalanced, isFalse);
      });

      test('→ unmatched bank transactions are in unreconciledItems', () {
        final date = DateTime(2025, 4, 5);
        final bankStmt = [
          bankTx(id: 'B1', date: date, amount: 100000, type: TxType.credit),
        ];
        final recon = service.reconcile(
          bankStatement: bankStmt,
          bookEntries: [], // nothing in books
          period: 'Apr 2025',
          accountNumber: '****9999',
          bankName: 'Axis Bank',
          bankBalance: 100000,
          bookBalance: 0,
        );
        expect(recon.unreconciledItems, isNotEmpty);
      });

      test('→ matched items are in reconciledItems', () {
        final date = DateTime(2025, 4, 5);
        final bankStmt = [
          bankTx(id: 'B1', date: date, amount: 100000, type: TxType.credit),
        ];
        final bookEntries = [
          bookEntry(id: 'K1', date: date, amount: 100000, type: TxType.credit),
        ];
        final recon = service.reconcile(
          bankStatement: bankStmt,
          bookEntries: bookEntries,
          period: 'Apr 2025',
          accountNumber: '****1111',
          bankName: 'ICICI Bank',
          bankBalance: 100000,
          bookBalance: 100000,
        );
        expect(recon.reconciledItems, isNotEmpty);
        expect(recon.unreconciledItems, isEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // detectTimingDifferences
    // -----------------------------------------------------------------------
    group('detectTimingDifferences', () {
      test('→ marks unmatched items as timing when date is recent (≤5 days)', () {
        final recentDate = DateTime.now().subtract(const Duration(days: 2));
        final item = BankReconItem(
          transactionId: 'B1',
          date: recentDate,
          description: 'NEFT payment',
          amount: 50000,
          type: TxType.credit,
          status: ReconItemStatus.unmatchedInBank,
        );
        final result = service.detectTimingDifferences([item]);
        expect(result.first.status, ReconItemStatus.timing);
      });

      test('→ keeps unmatchedInBank for old unmatched items', () {
        final oldDate = DateTime.now().subtract(const Duration(days: 30));
        final item = BankReconItem(
          transactionId: 'B2',
          date: oldDate,
          description: 'Old payment',
          amount: 50000,
          type: TxType.debit,
          status: ReconItemStatus.unmatchedInBank,
        );
        final result = service.detectTimingDifferences([item]);
        expect(result.first.status, ReconItemStatus.unmatchedInBank);
      });

      test('→ already matched items are not modified', () {
        final item = BankReconItem(
          transactionId: 'B3',
          date: DateTime.now(),
          description: 'ECS',
          amount: 20000,
          type: TxType.debit,
          status: ReconItemStatus.matched,
        );
        final result = service.detectTimingDifferences([item]);
        expect(result.first.status, ReconItemStatus.matched);
      });
    });

    // -----------------------------------------------------------------------
    // computeAdjustedBalance
    // -----------------------------------------------------------------------
    group('computeAdjustedBalance', () {
      test('→ adds unreconciled credits and subtracts unreconciled debits', () {
        final date = DateTime(2025, 4, 5);
        final creditItem = BankReconItem(
          transactionId: 'B1',
          date: date,
          description: 'Deposit in transit',
          amount: 200000,
          type: TxType.credit,
          status: ReconItemStatus.unmatchedInBooks,
        );
        final debitItem = BankReconItem(
          transactionId: 'B2',
          date: date,
          description: 'Cheque not presented',
          amount: 50000,
          type: TxType.debit,
          status: ReconItemStatus.unmatchedInBank,
        );
        final recon = BankReconciliation(
          accountNumber: '****1234',
          bankName: 'HDFC',
          period: 'Apr 2025',
          bankBalance: 1000000,
          bookBalance: 1150000,
          unreconciledItems: [creditItem, debitItem],
          reconciledItems: [],
        );
        // Adjusted = bankBalance + credits - debits = 1000000 + 200000 - 50000 = 1150000
        final adjusted = service.computeAdjustedBalance(recon);
        expect(adjusted, 1150000);
      });
    });

    // -----------------------------------------------------------------------
    // BankReconciliation model
    // -----------------------------------------------------------------------
    group('BankReconciliation model', () {
      test('→ isBalanced computed correctly', () {
        const recon = BankReconciliation(
          accountNumber: '****1234',
          bankName: 'SBI',
          period: 'Apr 2025',
          bankBalance: 500000,
          bookBalance: 500000,
          unreconciledItems: [],
          reconciledItems: [],
        );
        expect(recon.isBalanced, isTrue);
      });

      test('→ copyWith returns new instance', () {
        const original = BankReconciliation(
          accountNumber: '****1234',
          bankName: 'SBI',
          period: 'Apr 2025',
          bankBalance: 500000,
          bookBalance: 500000,
          unreconciledItems: [],
          reconciledItems: [],
        );
        final updated = original.copyWith(bankName: 'HDFC');
        expect(updated.bankName, 'HDFC');
        expect(identical(original, updated), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // BankReconItem model
    // -----------------------------------------------------------------------
    group('BankReconItem model', () {
      test('→ equality based on all fields', () {
        final date = DateTime(2025, 4, 5);
        final a = BankReconItem(
          transactionId: 'T1',
          date: date,
          description: 'NEFT',
          amount: 100000,
          type: TxType.credit,
          status: ReconItemStatus.matched,
        );
        final b = BankReconItem(
          transactionId: 'T1',
          date: date,
          description: 'NEFT',
          amount: 100000,
          type: TxType.credit,
          status: ReconItemStatus.matched,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('→ copyWith changes only specified field', () {
        final date = DateTime(2025, 4, 5);
        final original = BankReconItem(
          transactionId: 'T1',
          date: date,
          description: 'NEFT',
          amount: 100000,
          type: TxType.credit,
          status: ReconItemStatus.unmatchedInBank,
        );
        final updated = original.copyWith(status: ReconItemStatus.timing);
        expect(updated.status, ReconItemStatus.timing);
        expect(updated.transactionId, 'T1');
      });
    });
  });
}
