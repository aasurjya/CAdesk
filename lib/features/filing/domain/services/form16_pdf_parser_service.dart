import 'dart:io';

import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';

/// Parses a Form 16 PDF and extracts structured data into [Form16Data].
///
/// Uses text-based extraction with regex patterns. Falls back gracefully
/// if parsing fails — caller should handle null return by prompting
/// the user to continue with manual entry.
///
/// Requires `syncfusion_flutter_pdf` for text extraction (optional dep).
/// If not available, returns null immediately.
class Form16PdfParserService {
  const Form16PdfParserService();

  /// Attempts to parse [pdfFilePath] into a [Form16Data] model.
  ///
  /// Returns null if:
  /// - The file does not exist
  /// - The file is not a valid PDF
  /// - The required fields could not be extracted
  Future<Form16Data?> parse(String pdfFilePath) async {
    final file = File(pdfFilePath);
    if (!file.existsSync()) return null;

    try {
      final text = await _extractText(file);
      if (text == null || text.isEmpty) return null;

      return _parseText(text);
    } catch (_) {
      return null;
    }
  }

  /// Extracts raw text from PDF.
  ///
  /// Placeholder: real implementation would use `syncfusion_flutter_pdf`
  /// or a native PDF text extraction library.
  Future<String?> _extractText(File file) async {
    // TODO: Integrate syncfusion_flutter_pdf for real text extraction.
    // For now, return null so the caller falls back to manual entry.
    return null;
  }

  /// Parses extracted text into [Form16Data] using regex patterns.
  Form16Data? _parseText(String text) {
    final employerTan = _extract(text, r'TAN\s*[:\-]?\s*([A-Z]{4}\d{5}[A-Z])');
    final employeePan = _extract(text, r'PAN\s*[:\-]?\s*([A-Z]{5}\d{4}[A-Z])');
    final grossSalary = _extractAmount(
      text,
      r'Gross\s+Salary\s*[:\-]?\s*([\d,]+)',
    );
    final standardDeduction = _extractAmount(
      text,
      r'Standard\s+Deduction\s*[:\-]?\s*([\d,]+)',
    );
    final tdsDeducted = _extractAmount(
      text,
      r'Total\s+Tax\s+Deducted\s*[:\-]?\s*([\d,]+)',
    );
    final taxRegime =
        text.contains(RegExp(r'Old\s+Regime', caseSensitive: false))
        ? 'Old'
        : 'New';
    final employerName =
        _extract(text, r'Name\s+of\s+(?:the\s+)?Employer\s*[:\-]?\s*(.+)') ??
        'Unknown Employer';
    final employeeName =
        _extract(text, r'Name\s+of\s+(?:the\s+)?Employee\s*[:\-]?\s*(.+)') ??
        'Unknown';

    if (employeePan == null) return null;

    return Form16Data(
      certificateNumber: 'PDF-IMPORT-${DateTime.now().millisecondsSinceEpoch}',
      employerTan: employerTan ?? '',
      employerPan: '',
      employerName: employerName,
      employerAddress: const TdsAddress(
        line1: '',
        city: '',
        state: '',
        pincode: '',
      ),
      employeePan: employeePan,
      employeeName: employeeName,
      employeeAddress: const TdsAddress(
        line1: '',
        city: '',
        state: '',
        pincode: '',
      ),
      assessmentYear: _extractAssessmentYear(text) ?? 'AY 2026-27',
      periodFrom: DateTime(2025, 4, 1),
      periodTo: DateTime(2026, 3, 31),
      partA: const Form16PartA(quarterlyDetails: []),
      partB: Form16PartB(
        salaryBreakup: SalaryBreakup(
          grossSalary: grossSalary ?? 0,
          salaryAsPerSection17_1: grossSalary ?? 0,
          valueOfPerquisites17_2: 0,
          profitsInLieuOfSalary17_3: 0,
          exemptAllowances: 0,
          standardDeduction: standardDeduction ?? 75000,
          entertainmentAllowance: 0,
          professionalTax: 0,
        ),
        incomeFromHouseProperty: 0,
        incomeFromOtherSources: 0,
        deductions: ChapterVIADeductions.zero(),
        taxComputation: TaxComputation(
          totalTaxableIncome: (grossSalary ?? 0) - (standardDeduction ?? 75000),
          taxOnTotalIncome: 0,
          rebate87A: 0,
          surcharge: 0,
          educationCess: 0,
          totalTaxPayable: tdsDeducted ?? 0,
          reliefSection89: 0,
          netTaxPayable: tdsDeducted ?? 0,
          taxRegime: taxRegime,
        ),
      ),
    );
  }

  String? _extract(String text, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
    return match?.group(1)?.trim();
  }

  double? _extractAmount(String text, String pattern) {
    final raw = _extract(text, pattern);
    if (raw == null) return null;
    final cleaned = raw.replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(cleaned);
  }

  String? _extractAssessmentYear(String text) {
    final match = RegExp(
      r'Assessment\s+Year\s*[:\-]?\s*(AY\s*\d{4}-\d{2})',
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }
}
