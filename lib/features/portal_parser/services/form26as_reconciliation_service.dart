import 'package:ca_app/features/portal_parser/models/form26as_data.dart';
import 'package:ca_app/features/portal_parser/models/tds_entry_26as.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductee_entry.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:flutter/foundation.dart';

// --------------- Result models ---------------

/// Type of mismatch detected between Form 26AS and books of accounts.
enum MismatchType {
  amountDifference(label: 'Amount Difference'),
  missingInForm26As(label: 'Missing in Form 26AS'),
  missingInBooks(label: 'Missing in Books');

  const MismatchType({required this.label});
  final String label;
}

/// Immutable model representing a single TDS mismatch record.
@immutable
class TdsMismatch {
  const TdsMismatch({
    required this.deductorTan,
    required this.section,
    required this.mismatchType,
    required this.form26asPaise,
    required this.booksPaise,
  });

  final String deductorTan;
  final String section;
  final MismatchType mismatchType;

  /// TDS amount per Form 26AS, in paise.
  final int form26asPaise;

  /// TDS amount per books of accounts, in paise.
  final int booksPaise;

  /// Difference (form26asPaise − booksPaise), in paise.
  int get differencePaise => form26asPaise - booksPaise;

  TdsMismatch copyWith({
    String? deductorTan,
    String? section,
    MismatchType? mismatchType,
    int? form26asPaise,
    int? booksPaise,
  }) {
    return TdsMismatch(
      deductorTan: deductorTan ?? this.deductorTan,
      section: section ?? this.section,
      mismatchType: mismatchType ?? this.mismatchType,
      form26asPaise: form26asPaise ?? this.form26asPaise,
      booksPaise: booksPaise ?? this.booksPaise,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsMismatch &&
          runtimeType == other.runtimeType &&
          deductorTan == other.deductorTan &&
          section == other.section &&
          mismatchType == other.mismatchType &&
          form26asPaise == other.form26asPaise &&
          booksPaise == other.booksPaise;

  @override
  int get hashCode =>
      Object.hash(deductorTan, section, mismatchType, form26asPaise, booksPaise);
}

/// Immutable summary of a Form 26AS reconciliation run.
@immutable
class ReconciliationSummary {
  const ReconciliationSummary({
    required this.totalEntries,
    required this.bookedEntries,
    required this.unmatchedEntries,
    required this.overBookedEntries,
    required this.totalTdsCreditedPaise,
  });

  final int totalEntries;
  final int bookedEntries;
  final int unmatchedEntries;
  final int overBookedEntries;
  final int totalTdsCreditedPaise;

  ReconciliationSummary copyWith({
    int? totalEntries,
    int? bookedEntries,
    int? unmatchedEntries,
    int? overBookedEntries,
    int? totalTdsCreditedPaise,
  }) {
    return ReconciliationSummary(
      totalEntries: totalEntries ?? this.totalEntries,
      bookedEntries: bookedEntries ?? this.bookedEntries,
      unmatchedEntries: unmatchedEntries ?? this.unmatchedEntries,
      overBookedEntries: overBookedEntries ?? this.overBookedEntries,
      totalTdsCreditedPaise: totalTdsCreditedPaise ?? this.totalTdsCreditedPaise,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReconciliationSummary &&
          runtimeType == other.runtimeType &&
          totalEntries == other.totalEntries &&
          bookedEntries == other.bookedEntries &&
          unmatchedEntries == other.unmatchedEntries &&
          overBookedEntries == other.overBookedEntries &&
          totalTdsCreditedPaise == other.totalTdsCreditedPaise;

  @override
  int get hashCode => Object.hash(
    totalEntries,
    bookedEntries,
    unmatchedEntries,
    overBookedEntries,
    totalTdsCreditedPaise,
  );
}

/// Immutable result of reconciling Form 26AS data against filed TDS returns.
@immutable
class Form26AsReconciliationResult {
  const Form26AsReconciliationResult({
    required this.matchedEntries,
    required this.unmatchedEntries,
    required this.totalCreditedPaise,
    required this.totalMatchedPaise,
  });

  /// TDS entries from Form 26AS that have a matching filed TDS return (by TAN).
  final List<TdsEntry26As> matchedEntries;

  /// TDS entries from Form 26AS that have no matching filed TDS return.
  final List<TdsEntry26As> unmatchedEntries;

  /// Total TDS credited as per Form 26AS, in paise.
  final int totalCreditedPaise;

  /// Total TDS in matched entries, in paise.
  final int totalMatchedPaise;

  Form26AsReconciliationResult copyWith({
    List<TdsEntry26As>? matchedEntries,
    List<TdsEntry26As>? unmatchedEntries,
    int? totalCreditedPaise,
    int? totalMatchedPaise,
  }) {
    return Form26AsReconciliationResult(
      matchedEntries: matchedEntries ?? this.matchedEntries,
      unmatchedEntries: unmatchedEntries ?? this.unmatchedEntries,
      totalCreditedPaise: totalCreditedPaise ?? this.totalCreditedPaise,
      totalMatchedPaise: totalMatchedPaise ?? this.totalMatchedPaise,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsReconciliationResult &&
          runtimeType == other.runtimeType &&
          totalCreditedPaise == other.totalCreditedPaise &&
          totalMatchedPaise == other.totalMatchedPaise;

  @override
  int get hashCode => Object.hash(totalCreditedPaise, totalMatchedPaise);
}

// --------------- Service ---------------

/// Stateless singleton service for reconciling Form 26AS data against
/// internally filed TDS returns and deductee ledger entries.
class Form26AsReconciliationService {
  Form26AsReconciliationService._();

  static final Form26AsReconciliationService instance =
      Form26AsReconciliationService._();

  // --------------- public API ---------------

  /// Reconciles [form26as] data against the list of [filedReturns].
  ///
  /// Matching is performed by TAN: an entry in Form 26AS is considered
  /// "matched" if at least one filed return shares the same TAN.
  Form26AsReconciliationResult reconcile(
    Form26AsData form26as,
    List<TdsReturn> filedReturns,
  ) {
    final filedTans = filedReturns.map((r) => r.tan.toUpperCase()).toSet();

    final matched = <TdsEntry26As>[];
    final unmatched = <TdsEntry26As>[];

    for (final entry in form26as.tdsEntries) {
      if (filedTans.contains(entry.deductorTan.toUpperCase())) {
        matched.add(entry);
      } else {
        unmatched.add(entry);
      }
    }

    final totalMatchedPaise =
        matched.fold<int>(0, (sum, e) => sum + e.tdsDeducted);

    return Form26AsReconciliationResult(
      matchedEntries: matched,
      unmatchedEntries: unmatched,
      totalCreditedPaise: form26as.totalTdsCredited,
      totalMatchedPaise: totalMatchedPaise,
    );
  }

  /// Finds mismatches between [data] (Form 26AS) and [entries] (books).
  ///
  /// Matching is done by section code.  When the TDS amount in the books
  /// (converted to paise) differs from the Form 26AS amount, a [TdsMismatch]
  /// is returned.
  List<TdsMismatch> findMismatches(
    Form26AsData data,
    List<TdsDeducteeEntry> entries,
  ) {
    final mismatches = <TdsMismatch>[];

    for (final form26asEntry in data.tdsEntries) {
      // Find a matching deductee entry by section.
      final bookEntry = _findMatchingEntry(entries, form26asEntry.section);
      if (bookEntry == null) continue;

      final booksPaise = (bookEntry.tdsDeducted * 100).round();
      final form26asPaise = form26asEntry.tdsDeducted;

      if (booksPaise != form26asPaise) {
        mismatches.add(TdsMismatch(
          deductorTan: form26asEntry.deductorTan,
          section: form26asEntry.section,
          mismatchType: MismatchType.amountDifference,
          form26asPaise: form26asPaise,
          booksPaise: booksPaise,
        ));
      }
    }

    return mismatches;
  }

  /// Computes a high-level [ReconciliationSummary] from [data].
  ReconciliationSummary computeReconciliationSummary(Form26AsData data) {
    int booked = 0;
    int unmatched = 0;
    int overBooked = 0;

    for (final entry in data.tdsEntries) {
      switch (entry.status) {
        case BookingStatus.booked:
          booked++;
        case BookingStatus.unmatched:
          unmatched++;
        case BookingStatus.overBooked:
          overBooked++;
      }
    }

    return ReconciliationSummary(
      totalEntries: data.tdsEntries.length,
      bookedEntries: booked,
      unmatchedEntries: unmatched,
      overBookedEntries: overBooked,
      totalTdsCreditedPaise: data.totalTdsCredited,
    );
  }

  // --------------- private helpers ---------------

  TdsDeducteeEntry? _findMatchingEntry(
    List<TdsDeducteeEntry> entries,
    String section,
  ) {
    for (final e in entries) {
      if (e.section == section) return e;
    }
    return null;
  }
}
