import 'package:ca_app/features/tds/domain/models/tds_challan.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductee_entry.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';

/// Static service for TDS return form validation, due dates, and linking.
class TdsReturnFormService {
  TdsReturnFormService._();

  // TAN format: 4 alpha + 5 numeric + 1 alpha (e.g. MUMA12345B)
  static final RegExp _tanPattern = RegExp(r'^[A-Z]{4}\d{5}[A-Z]$');

  // PAN format: 5 alpha + 4 numeric + 1 alpha (e.g. ABCDE1234F)
  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}\d{4}[A-Z]$');

  /// Validates a [TdsReturnForm] and returns a list of error messages.
  ///
  /// An empty list means the form is valid.
  static List<String> validate(TdsReturnForm form) {
    final errors = <String>[];

    // TAN validation
    if (form.deductorTan.isEmpty) {
      errors.add('Deductor TAN is required');
    } else if (!_tanPattern.hasMatch(form.deductorTan)) {
      errors.add(
        'Invalid TAN format. Expected 4 alpha + 5 numeric + 1 alpha',
      );
    }

    // PAN validation
    if (form.deductorPan.isEmpty) {
      errors.add('Deductor PAN is required');
    } else if (!_panPattern.hasMatch(form.deductorPan)) {
      errors.add(
        'Invalid PAN format. Expected 5 alpha + 4 numeric + 1 alpha',
      );
    }

    // At least one entry
    if (form.entries.isEmpty) {
      errors.add('At least one deductee entry is required');
    }

    // Every entry must have a section
    for (final entry in form.entries) {
      if (entry.section.isEmpty) {
        errors.add('Entry "${entry.deducteeName}" is missing a section code');
      }
    }

    // Challan total must cover deductee total
    final totalDeducted =
        form.entries.fold(0.0, (sum, e) => sum + e.tdsDeducted);
    final totalChallan =
        form.challans.fold(0.0, (sum, TdsChallan c) => sum + c.totalAmount);
    if (totalChallan < totalDeducted) {
      errors.add(
        'Total challan amount ($totalChallan) is less than total TDS '
        'deducted ($totalDeducted)',
      );
    }

    return errors;
  }

  /// Returns the due date for filing a TDS return.
  ///
  /// - 24Q / 26Q / 27Q: Q1→Jul 31, Q2→Oct 31, Q3→Jan 31, Q4→May 31
  /// - 27EQ (TCS):       Q1→Jul 15, Q2→Oct 15, Q3→Jan 15, Q4→May 15
  static DateTime getDueDate({
    required TdsFormType formType,
    required TdsQuarter quarter,
    required String financialYear,
  }) {
    final startYear = _startYear(financialYear);
    final isTcs = formType == TdsFormType.form27EQ;
    final day = isTcs ? 15 : 31;

    switch (quarter) {
      case TdsQuarter.q1:
        return DateTime(startYear, 7, day);
      case TdsQuarter.q2:
        return DateTime(startYear, 10, day);
      case TdsQuarter.q3:
        return DateTime(startYear + 1, 1, day);
      case TdsQuarter.q4:
        return DateTime(startYear + 1, 5, day);
    }
  }

  /// Returns `true` if the given form is past its due date.
  ///
  /// - If [TdsReturnForm.filedDate] is set, compares it to the due date.
  /// - If not filed yet, compares the current date to the due date.
  static bool isOverdue(TdsReturnForm form) {
    final dueDate = getDueDate(
      formType: form.formType,
      quarter: form.quarter,
      financialYear: form.financialYear,
    );

    final effectiveDate = form.filedDate ?? DateTime.now();
    return effectiveDate.isAfter(dueDate);
  }

  /// Calculates the late filing fee under Section 234E.
  ///
  /// Fee is Rs 200 per day of delay, capped at the total TDS amount.
  /// Returns 0 if filing is on or before the due date.
  static double calculateLateFee({
    required DateTime filingDate,
    required DateTime dueDate,
    required double totalTds,
  }) {
    if (!filingDate.isAfter(dueDate)) return 0;

    final daysLate = filingDate.difference(dueDate).inDays;
    final fee = daysLate * 200.0;
    return fee < totalTds ? fee : totalTds;
  }

  /// Links deductee entries to challans by matching section code and
  /// payment month.
  ///
  /// Returns a new list of entries with [TdsDeducteeEntry.challanId] set
  /// where a matching challan is found. Entries without a match are returned
  /// unchanged.
  static List<TdsDeducteeEntry> linkChallans({
    required List<TdsDeducteeEntry> entries,
    required List<TdsChallan> challans,
  }) {
    return entries.map((entry) {
      final paymentMonth = entry.dateOfPayment.month;

      for (final challan in challans) {
        if (challan.section == entry.section &&
            challan.month == paymentMonth) {
          return entry.copyWith(challanId: challan.id);
        }
      }

      return entry;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Extracts the start year from a financial year string like "2025-26".
  static int _startYear(String financialYear) {
    return int.parse(financialYear.split('-').first);
  }
}
