import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_assets.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_balance_sheet.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_equity.dart';

/// Stateless service that derives a Schedule III Balance Sheet from a list of
/// [JournalEntry] items.
///
/// All amounts are in paise (int).
class ScheduleIIIService {
  ScheduleIIIService._();

  /// Computes a [ScheduleIIIBalanceSheet] by aggregating [entries] into their
  /// respective account heads.
  ///
  /// Liability / equity heads are accumulated from credit entries (isDebit = false).
  /// Asset heads are accumulated from debit entries (isDebit = true).
  /// Both debit and credit entries for the same head are summed with sign, so
  /// contra entries reduce the balance.
  static ScheduleIIIBalanceSheet computeBalanceSheet({
    required List<JournalEntry> entries,
    required int financialYear,
  }) {
    // Accumulate signed amounts per account head.
    // Credit entries for liability/equity heads increase the balance.
    // Debit entries for asset heads increase the balance.
    final Map<AccountHead, int> totals = {};

    for (final entry in entries) {
      final current = totals[entry.accountHead] ?? 0;
      // For balance sheet purposes we track net credit for liabilities/equity
      // and net debit for assets — both stored as positive integers.
      final signed = entry.isDebit ? entry.amount : -entry.amount;
      totals[entry.accountHead] = current + signed;
    }

    // Helper: returns absolute credit balance for liability/equity heads.
    int creditBalance(AccountHead head) {
      final v = totals[head] ?? 0;
      // Credit entries were negated above, so a net negative value = net credit.
      return v < 0 ? -v : 0;
    }

    // Helper: returns absolute debit balance for asset heads.
    int debitBalance(AccountHead head) {
      final v = totals[head] ?? 0;
      return v > 0 ? v : 0;
    }

    final equity = ScheduleIIIEquity(
      shareCapital: creditBalance(AccountHead.shareCapital),
      reservesAndSurplus: creditBalance(AccountHead.reservesAndSurplus),
      longTermBorrowings: creditBalance(AccountHead.longTermBorrowings),
      tradePayables: creditBalance(AccountHead.tradePayables),
      otherCurrentLiabilities:
          creditBalance(AccountHead.otherCurrentLiabilities),
    );

    final assets = ScheduleIIIAssets(
      fixedAssets: debitBalance(AccountHead.fixedAssets),
      investments: debitBalance(AccountHead.investments),
      inventories: debitBalance(AccountHead.inventories),
      tradeReceivables: debitBalance(AccountHead.tradeReceivables),
      cashAndCashEquivalents:
          debitBalance(AccountHead.cashAndCashEquivalents),
      otherCurrentAssets: debitBalance(AccountHead.otherCurrentAssets),
    );

    return ScheduleIIIBalanceSheet(
      financialYear: financialYear,
      equity: equity,
      assets: assets,
      notes: const [],
    );
  }
}
