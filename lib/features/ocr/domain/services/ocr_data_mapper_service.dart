import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/journal_entry.dart';
import 'package:ca_app/features/ocr/domain/models/tds_entry.dart';

/// Stateless singleton that maps extracted OCR data to downstream CA workflow
/// objects such as ITR income schedules, TDS return entries, and journal entries.
class OcrDataMapperService {
  OcrDataMapperService._();

  static final OcrDataMapperService instance = OcrDataMapperService._();

  // -------------------------------------------------------------------------
  // ITR Income Mapping
  // -------------------------------------------------------------------------

  /// Maps [ExtractedForm16] to a schedule-name → paise map suitable for
  /// pre-filling ITR Salary Schedule (Schedule S / Part B of Form 16).
  ///
  /// Keys correspond to ITR field names used in the filing feature.
  Map<String, int> mapToItrIncome(ExtractedForm16 form16) {
    return Map.unmodifiable({
      'grossSalary': form16.grossSalary,
      'standardDeduction': form16.standardDeduction,
      'professionalTax': form16.professionalTax,
      'taxableIncome': form16.taxableIncome,
      'tdsDeducted': form16.tdsDeducted,
    });
  }

  // -------------------------------------------------------------------------
  // TDS Entry Mapping
  // -------------------------------------------------------------------------

  /// Creates a [TdsEntry] from an [ExtractedForm16], ready for pre-filling
  /// Schedule TDS in an ITR return or a TDS reconciliation workflow.
  TdsEntry mapToTdsEntry(ExtractedForm16 form16) {
    return TdsEntry(
      deducteePan: form16.employeePan,
      deductorTan: form16.employerTan,
      assessmentYear: form16.assessmentYear,
      grossAmount: form16.grossSalary,
      tdsDeducted: form16.tdsDeducted,
    );
  }

  // -------------------------------------------------------------------------
  // Journal Entry Mapping
  // -------------------------------------------------------------------------

  /// Converts each [ExtractedTransaction] in [stmt] into a [JournalEntry].
  ///
  /// Debit transactions → [isDebit] = true
  /// Credit transactions → [isDebit] = false
  ///
  /// Returns an unmodifiable list in the same order as the original
  /// transactions list.
  List<JournalEntry> mapTransactionsToJournalEntries(
    ExtractedBankStatement stmt,
  ) {
    final entries = stmt.transactions
        .map((tx) {
          final isDebit = tx.debit > 0;
          final amount = isDebit ? tx.debit : tx.credit;
          return JournalEntry(
            date: tx.date,
            description: tx.description,
            amount: amount,
            isDebit: isDebit,
            referenceNumber: tx.referenceNumber,
          );
        })
        .toList(growable: false);

    return List.unmodifiable(entries);
  }
}
