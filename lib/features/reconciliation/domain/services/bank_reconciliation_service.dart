import '../models/bank_recon_item.dart';
import '../models/bank_reconciliation.dart';

// ---------------------------------------------------------------------------
// Input data-transfer objects
// ---------------------------------------------------------------------------

/// A single transaction from a bank statement.
class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    this.description = '',
  });

  final String id;
  final DateTime date;

  /// Amount in paise.
  final int amount;
  final TxType type;
  final String description;
}

/// A single entry from the accounting books.
class BookEntry {
  const BookEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    this.description = '',
  });

  final String id;
  final DateTime date;

  /// Amount in paise.
  final int amount;
  final TxType type;
  final String description;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Stateless service for reconciling a bank account statement against the
/// corresponding book entries for a given period.
///
/// ### Matching Criteria
/// A bank transaction matches a book entry when ALL of the following hold:
/// - Same debit/credit direction ([TxType])
/// - Date within ±3 days (common for ECS/NEFT T+1 settlement, cheques)
/// - Amount within ₹1 (100 paise) — rounding tolerance
///
/// ### Timing Differences
/// Unmatched items with a transaction date within the last 5 days are
/// reclassified as [ReconItemStatus.timing] because the matching entry is
/// likely still in transit (T+1 settlement, post-dated cheques).
///
/// ### Usage
/// ```dart
/// final recon = BankReconciliationService.instance.reconcile(
///   bankStatement: bankTxns,
///   bookEntries: bookEntries,
///   period: 'Apr 2025',
///   accountNumber: '****1234',
///   bankName: 'HDFC Bank',
///   bankBalance: 50000,
///   bookBalance: 50000,
/// );
/// ```
class BankReconciliationService {
  BankReconciliationService._();

  static final BankReconciliationService instance =
      BankReconciliationService._();

  /// Maximum date difference (in days) to consider a match.
  static const int _maxDateDiffDays = 3;

  /// Maximum amount difference (in paise) to consider a match (₹1 rounding).
  static const int _maxAmountDiffPaise = 100;

  /// Transactions within this many days of today are reclassified as timing.
  static const int _timingWindowDays = 5;

  /// Reconciles a bank statement against book entries for a given period.
  ///
  /// Returns a [BankReconciliation] with matched and unmatched items.
  BankReconciliation reconcile({
    required List<BankTransaction> bankStatement,
    required List<BookEntry> bookEntries,
    required String period,
    required String accountNumber,
    required String bankName,
    required int bankBalance,
    required int bookBalance,
  }) {
    final reconciled = <BankReconItem>[];
    final unreconciled = <BankReconItem>[];

    for (final bankTx in bankStatement) {
      final item = matchTransactions(bankTx, bookEntries);
      if (item.status == ReconItemStatus.matched) {
        reconciled.add(item);
      } else {
        unreconciled.add(item);
      }
    }

    final withTimingUpdates = detectTimingDifferences(unreconciled);

    return BankReconciliation(
      accountNumber: accountNumber,
      bankName: bankName,
      period: period,
      bankBalance: bankBalance,
      bookBalance: bookBalance,
      unreconciledItems: withTimingUpdates,
      reconciledItems: reconciled,
    );
  }

  /// Attempts to match a single [BankTransaction] against a list of [BookEntry]s.
  ///
  /// Returns a [BankReconItem] with [ReconItemStatus.matched] if a match is
  /// found, or [ReconItemStatus.unmatchedInBank] if no match could be made.
  BankReconItem matchTransactions(
    BankTransaction bank,
    List<BookEntry> books,
  ) {
    for (final book in books) {
      if (_isMatch(bank, book)) {
        return BankReconItem(
          transactionId: bank.id,
          date: bank.date,
          description: bank.description,
          amount: bank.amount,
          type: bank.type,
          status: ReconItemStatus.matched,
        );
      }
    }

    return BankReconItem(
      transactionId: bank.id,
      date: bank.date,
      description: bank.description,
      amount: bank.amount,
      type: bank.type,
      status: ReconItemStatus.unmatchedInBank,
    );
  }

  /// Reclassifies recently-dated unmatched items as [ReconItemStatus.timing].
  ///
  /// Timing differences occur when a transaction appears in the bank statement
  /// but the corresponding book entry has not yet been recorded (e.g. bank
  /// charges or NEFT credits in T+1 settlement, cheques in transit).
  ///
  /// Items with a transaction date within [_timingWindowDays] days of today
  /// are candidates for reclassification.
  List<BankReconItem> detectTimingDifferences(List<BankReconItem> unmatched) {
    final today = DateTime.now();
    return unmatched.map((item) {
      if (item.status != ReconItemStatus.unmatchedInBank &&
          item.status != ReconItemStatus.unmatchedInBooks) {
        return item;
      }
      final ageDays = today.difference(item.date).inDays;
      if (ageDays <= _timingWindowDays) {
        return item.copyWith(status: ReconItemStatus.timing);
      }
      return item;
    }).toList();
  }

  /// Computes the adjusted bank balance after accounting for unreconciled items.
  ///
  /// Adjusted balance = bankBalance
  ///   + unreconciled credits (deposits in transit — in books, not yet in bank)
  ///   - unreconciled debits  (cheques not yet presented)
  ///
  /// When the adjusted balance equals the book balance, the reconciliation
  /// is considered complete.
  int computeAdjustedBalance(BankReconciliation recon) {
    var adjusted = recon.bankBalance;
    for (final item in recon.unreconciledItems) {
      if (item.type == TxType.credit) {
        adjusted += item.amount;
      } else {
        adjusted -= item.amount;
      }
    }
    return adjusted;
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  bool _isMatch(BankTransaction bank, BookEntry book) {
    if (bank.type != book.type) return false;
    final dateDiff = bank.date.difference(book.date).inDays.abs();
    if (dateDiff > _maxDateDiffDays) return false;
    final amountDiff = (bank.amount - book.amount).abs();
    if (amountDiff > _maxAmountDiffPaise) return false;
    return true;
  }
}
