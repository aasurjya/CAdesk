import 'dart:convert';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';
import 'package:ca_app/features/filing/domain/services/tax_computation_engine.dart';
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
    final taxResult = TaxComputationEngine.compare(data);

    return {
      'ITR': {
        'ITR1': {
          'PersonalInfo': _personalInfo(data, assessmentYear),
          'FilingStatus': _filingStatus(data),
          'ITR1_IncomeDeductions': _incomeDeductions(data),
          'TaxComputation': _taxComputation(data, taxResult),
          'ScheduleTDS': _scheduleTds(data),
          'ScheduleTaxPayment': _scheduleTaxPayment(data),
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

  /// Populates the TaxComputation block from [TaxComputationEngine] results
  /// and the TDS/taxes paid data from [Itr1FormData].
  static Map<String, dynamic> _taxComputation(
    Itr1FormData data,
    TaxRegimeResult taxResult,
  ) {
    final isNewRegime = data.selectedRegime == TaxRegime.newRegime;
    final baseTax = isNewRegime
        ? taxResult.newRegimeTaxBeforeCess
        : taxResult.oldRegimeTaxBeforeCess;
    final surcharge = isNewRegime
        ? taxResult.newRegimeSurcharge
        : taxResult.oldRegimeSurcharge;
    final cess = isNewRegime
        ? taxResult.newRegimeCess
        : taxResult.oldRegimeCess;
    final totalTax = isNewRegime
        ? taxResult.newRegimeTax
        : taxResult.oldRegimeTax;

    // Rebate u/s 87A: if base tax is zero but income > 0, rebate was applied.
    final taxableIncome = isNewRegime
        ? taxResult.newRegimeTaxableIncome
        : taxResult.oldRegimeTaxableIncome;
    final rebateThreshold = isNewRegime ? 1200000.0 : 500000.0;
    final rebate87A = (taxableIncome > 0 && taxableIncome <= rebateThreshold)
        ? baseTax
        : 0.0;

    final grossTaxLiability = _toRupees(totalTax);
    final totalTaxPaid = _toRupees(data.tdsPaymentSummary.totalTaxesPaid);
    final balance = grossTaxLiability - totalTaxPaid;

    return {
      'TaxPayableOnTI': _toRupees(baseTax),
      'Surcharge': _toRupees(surcharge),
      'Rebate87A': _toRupees(rebate87A),
      'TaxPayableAfterRebate': _toRupees(baseTax - rebate87A),
      'EducationCess': _toRupees(cess),
      'GrossTaxLiability': grossTaxLiability,
      'TotalTaxAndInterest': grossTaxLiability,
      'TotalTaxPaid': totalTaxPaid,
      'BalTaxPayable': balance > 0 ? balance : 0,
      'Refund': balance < 0 ? -balance : 0,
    };
  }

  /// Schedule TDS — TDS deducted on salary and other income.
  static Map<String, dynamic> _scheduleTds(Itr1FormData data) {
    final tds = data.tdsPaymentSummary;
    return {
      'TDSonSalary': _toRupees(tds.tdsOnSalary),
      'TDSonOtherThanSalary': _toRupees(tds.tdsOnOtherIncome),
      'TotalTDS': _toRupees(tds.totalTds),
    };
  }

  /// Schedule Tax Payment — advance tax and self-assessment tax.
  static Map<String, dynamic> _scheduleTaxPayment(Itr1FormData data) {
    final tds = data.tdsPaymentSummary;
    return {
      'AdvanceTaxQ1': _toRupees(tds.advanceTaxQ1),
      'AdvanceTaxQ2': _toRupees(tds.advanceTaxQ2),
      'AdvanceTaxQ3': _toRupees(tds.advanceTaxQ3),
      'AdvanceTaxQ4': _toRupees(tds.advanceTaxQ4),
      'TotalAdvanceTax': _toRupees(tds.totalAdvanceTax),
      'SelfAssessmentTax': _toRupees(tds.selfAssessmentTax),
      'TotalTaxPayments': _toRupees(
        tds.totalAdvanceTax + tds.selfAssessmentTax,
      ),
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
