import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_assets.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_equity.dart';

/// Account heads used for journal entry classification.
enum AccountHead {
  // Equity & Liabilities
  shareCapital,
  reservesAndSurplus,
  longTermBorrowings,
  tradePayables,
  otherCurrentLiabilities,

  // Assets
  fixedAssets,
  investments,
  inventories,
  tradeReceivables,
  cashAndCashEquivalents,
  otherCurrentAssets,
}

/// A single journal entry used as input for balance sheet computation.
///
/// All amounts are in paise (int).
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.date,
    required this.accountHead,
    required this.amount,
    required this.isDebit,
  });

  final String id;
  final DateTime date;
  final AccountHead accountHead;

  /// Amount in paise.
  final int amount;

  /// True if this is a debit entry; false if credit.
  final bool isDebit;

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    AccountHead? accountHead,
    int? amount,
    bool? isDebit,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      accountHead: accountHead ?? this.accountHead,
      amount: amount ?? this.amount,
      isDebit: isDebit ?? this.isDebit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// A note to the Schedule III Balance Sheet.
class BalanceSheetNote {
  const BalanceSheetNote({
    required this.noteNumber,
    required this.heading,
    required this.description,
  });

  final int noteNumber;
  final String heading;
  final String description;

  BalanceSheetNote copyWith({
    int? noteNumber,
    String? heading,
    String? description,
  }) {
    return BalanceSheetNote(
      noteNumber: noteNumber ?? this.noteNumber,
      heading: heading ?? this.heading,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BalanceSheetNote &&
        other.noteNumber == noteNumber &&
        other.heading == heading &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(noteNumber, heading, description);
}

/// Immutable Schedule III Balance Sheet as mandated by the Companies Act 2013.
///
/// Equity & Liabilities must always equal Total Assets.
/// All amounts are in paise (int).
class ScheduleIIIBalanceSheet {
  const ScheduleIIIBalanceSheet({
    required this.financialYear,
    required this.equity,
    required this.assets,
    required this.notes,
  });

  /// Financial year represented as the ending year integer.
  /// e.g. 2025 = FY 2024-25.
  final int financialYear;

  /// Equity and all liabilities section.
  final ScheduleIIIEquity equity;

  /// Assets section.
  final ScheduleIIIAssets assets;

  /// Notes to accounts.
  final List<BalanceSheetNote> notes;

  /// Total equity and liabilities (the right side of the balance sheet).
  int get totalEquityAndLiabilities => equity.total;

  /// Total assets (the left side of the balance sheet).
  int get totalAssets => assets.total;

  /// Whether the balance sheet is balanced (assets == equity + liabilities).
  bool get isBalanced => totalAssets == totalEquityAndLiabilities;

  ScheduleIIIBalanceSheet copyWith({
    int? financialYear,
    ScheduleIIIEquity? equity,
    ScheduleIIIAssets? assets,
    List<BalanceSheetNote>? notes,
  }) {
    return ScheduleIIIBalanceSheet(
      financialYear: financialYear ?? this.financialYear,
      equity: equity ?? this.equity,
      assets: assets ?? this.assets,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleIIIBalanceSheet) return false;
    if (other.financialYear != financialYear) return false;
    if (other.equity != equity) return false;
    if (other.assets != assets) return false;
    if (other.notes.length != notes.length) return false;
    for (int i = 0; i < notes.length; i++) {
      if (other.notes[i] != notes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(financialYear, equity, assets, notes.length);
}
