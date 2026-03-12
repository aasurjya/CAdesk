import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_invoice.dart';
import 'package:flutter/foundation.dart';

/// Sealed base class for any structured data extracted from an OCR document.
///
/// Use pattern matching (switch expression) to handle each variant.
@immutable
sealed class OcrExtractedData {
  const OcrExtractedData();
}

/// Extracted data variant for Form 16 documents.
@immutable
final class Form16ExtractedData extends OcrExtractedData {
  const Form16ExtractedData(this.data);

  final ExtractedForm16 data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16ExtractedData &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Extracted data variant for bank statement documents.
@immutable
final class BankStatementExtractedData extends OcrExtractedData {
  const BankStatementExtractedData(this.data);

  final ExtractedBankStatement data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankStatementExtractedData &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Extracted data variant for invoice documents.
@immutable
final class InvoiceExtractedData extends OcrExtractedData {
  const InvoiceExtractedData(this.data);

  final ExtractedInvoice data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceExtractedData &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Extracted data variant for unrecognised or unsupported document types.
@immutable
final class UnknownExtractedData extends OcrExtractedData {
  const UnknownExtractedData({this.rawText = ''});

  final String rawText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownExtractedData &&
          runtimeType == other.runtimeType &&
          rawText == other.rawText;

  @override
  int get hashCode => rawText.hashCode;
}
