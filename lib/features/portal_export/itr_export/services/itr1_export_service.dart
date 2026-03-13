import 'dart:convert';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr_checksum_service.dart';

/// Stateless service that exports [Itr1FormData] to the ITD e-Filing 2.0
/// JSON format and wraps the result in an [ItrExportResult].
///
/// JSON structure follows the ITD e-Filing 2.0 ITR-1 (Sahaj) schema:
/// ```
/// {
///   "ITR": {
///     "ITR1": {
///       "PersonalInfo": {...},
///       "FilingStatus": {...},
///       "ITR1_IncomeDeductions": {...},
///       "TaxComputation": {...}
///     }
///   }
/// }
/// ```
///
/// All monetary amounts are encoded as **integers in rupees**.
class Itr1ExportService {
  Itr1ExportService._();

  /// Exports [data] for the given [assessmentYear] (format "YYYY-YY").
  ///
  /// Returns an [ItrExportResult] with the JSON payload, SHA-256 checksum,
  /// and any validation errors.
  static ItrExportResult export(Itr1FormData data, String assessmentYear) {
    final payload = _buildPayload(data, assessmentYear);
    final jsonString = jsonEncode(payload);
    final checksum = ItrChecksumService.computeSha256(jsonString);

    return ItrExportResult(
      itrType: ItrType.itr1,
      jsonPayload: jsonString,
      checksum: checksum,
      exportedAt: DateTime.now(),
      assessmentYear: assessmentYear,
      panNumber: data.personalInfo.pan,
      validationErrors: const [],
    );
  }

  // ---------------------------------------------------------------------------
  // JSON structure builders
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _buildPayload(
    Itr1FormData data,
    String assessmentYear,
  ) {
    return {
      'ITR': {
        'ITR1': {
          'PersonalInfo': _personalInfo(data, assessmentYear),
          'FilingStatus': _filingStatus(data),
          'ITR1_IncomeDeductions': _incomeDeductions(data),
          'TaxComputation': _taxComputation(),
        },
      },
    };
  }

  static Map<String, dynamic> _personalInfo(
    Itr1FormData data,
    String assessmentYear,
  ) {
    final pi = data.personalInfo;
    return {
      'AssesseeName': {
        'FirstName': pi.firstName,
        'MiddleName': pi.middleName,
        'SurNameOrOrgName': pi.lastName,
      },
      'PAN': pi.pan,
      'DOB': _formatDate(pi.dateOfBirth),
      'EmployerCategory': 'OTH',
      'AadhaarCardNo': pi.aadhaarNumber,
      'AssessmentYear': assessmentYear,
    };
  }

  static Map<String, dynamic> _filingStatus(Itr1FormData data) {
    return {
      'ReturnFileSec': 11, // Section 139(1) — original return, on due date
      'SeqNoOfSelf': '1',
      'OptOutNewTaxRegime': data.selectedRegime == TaxRegime.oldRegime
          ? 'Y'
          : 'N',
    };
  }

  static Map<String, dynamic> _incomeDeductions(Itr1FormData data) {
    final s = data.salaryIncome;
    final hp = data.housePropertyIncome;
    final os = data.otherSourceIncome;
    final grossSalary = _toRupees(s.grossSalary);
    final netSalary = _toRupees(s.netSalary);
    final incomeFromHp = _toRupees(hp.incomeFromHouseProperty);
    final grossRentReceived = _toRupees(hp.annualLetableValue);
    final incomeOthSrc = _toRupees(os.total);
    final grossTotIncome = _toRupees(data.grossTotalIncome);
    final totalDeductions = _toRupees(data.allowableDeductions);
    final incomeAfterDeduction = _toRupees(data.taxableIncome);

    return {
      'GrossSalary': grossSalary,
      'NetSalary': netSalary,
      'IncomeFromHP': incomeFromHp,
      'GrossRentReceived': grossRentReceived,
      'TotalIncomeOfHP': incomeFromHp,
      'IncomeOthSrc': incomeOthSrc,
      'GrossTotIncome': grossTotIncome,
      'TotalDeductions': totalDeductions,
      'IncomeAfterDeduction': incomeAfterDeduction,
    };
  }

  /// Returns a zeroed-out TaxComputation block.
  ///
  /// Full tax computation is handled by the [TaxComputationEngine]; this
  /// service only structures the JSON skeleton for portal submission.
  static Map<String, dynamic> _taxComputation() {
    return {
      'TaxPayableOnTI': 0,
      'Rebate87A': 0,
      'TaxPayableAfterRebate': 0,
      'EducationCess': 0,
      'GrossTaxLiability': 0,
      'TotalTaxAndInterest': 0,
      'TotalTaxPaid': 0,
      'BalTaxPayable': 0,
      'Refund': 0,
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts a double rupee value to an integer (floor division).
  ///
  /// ITD JSON requires all monetary amounts as integers in rupees.
  static int _toRupees(double amount) => amount.truncate();

  static String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
