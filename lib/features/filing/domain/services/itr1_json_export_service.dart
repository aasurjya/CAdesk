import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';

/// Converts [Itr1FormData] + [TaxRegimeResult] into a [Map] matching the
/// ITD JSON schema structure for ITR-1 (Sahaj) filing.
///
/// The CA downloads this JSON → uploads it to the Income Tax portal.
class Itr1JsonExportService {
  Itr1JsonExportService._();

  /// Generate the full ITR-1 JSON structure.
  static Map<String, dynamic> export({
    required Itr1FormData formData,
    required TaxRegimeResult taxResult,
    required String assessmentYear,
    required String filingType, // 'Original' or 'Revised'
  }) {
    return {
      'ITR': {
        'ITR1': {
          'CreationInfo': _creationInfo(assessmentYear, filingType),
          'PartA_GEN1': _personalInfo(formData),
          'ScheduleS': _salarySchedule(formData),
          'ScheduleHP': _housePropertySchedule(formData),
          'ScheduleOS': _otherSourceSchedule(formData),
          'ScheduleVIA': _deductionsSchedule(formData),
          'PartBTI': _partBTotalIncome(formData, taxResult),
          'PartBTTI': _partBTaxComputation(taxResult),
          'Verification': _verification(formData),
        },
      },
    };
  }

  static Map<String, dynamic> _creationInfo(
    String assessmentYear,
    String filingType,
  ) {
    return {
      'SWVersionNo': 'CADesk-1.0',
      'SWCreatedBy': 'SW',
      'IntermediaryCity': '',
      'Aboression': assessmentYear,
      'FilingType': filingType,
    };
  }

  static Map<String, dynamic> _personalInfo(Itr1FormData data) {
    final pi = data.personalInfo;
    return {
      'PersonalInfo': {
        'AssesseeName': {
          'FirstName': pi.firstName,
          'MiddleName': pi.middleName,
          'SurNameOrOrgName': pi.lastName,
        },
        'PAN': pi.pan,
        'AadhaarCardNo': pi.aadhaarNumber,
        'DOB': _formatDate(pi.dateOfBirth),
        'Email': pi.email,
        'MobileNo': pi.mobile,
        'Address': {
          'FlatDoorBlockNo': pi.flatDoorBlock,
          'PremisesName': pi.street,
          'CityOrTownOrDistrict': pi.city,
          'StateCode': pi.state,
          'PinCode': pi.pincode,
        },
      },
      'FilingStatus': {
        'ReturnFileSec': 11, // Section 139(1) — on or before due date
        'OptOutNewTaxRegime': data.selectedRegime == TaxRegime.oldRegime
            ? 'Y'
            : 'N',
      },
    };
  }

  static Map<String, dynamic> _salarySchedule(Itr1FormData data) {
    final s = data.salaryIncome;
    return {
      'Salaries': s.grossSalary,
      'AllwncExemptUs10': s.allowancesExemptUnderSection10,
      'Perquisites': s.valueOfPerquisites,
      'ProfitsInSalary': s.profitsInLieuOfSalary,
      'DeductionUs16': s.standardDeduction,
      'NetSalary': s.netSalary,
    };
  }

  static Map<String, dynamic> _housePropertySchedule(Itr1FormData data) {
    final hp = data.housePropertyIncome;
    return {
      'AnnualLetableValue': hp.annualLetableValue,
      'MunicipalTaxPaid': hp.municipalTaxesPaid,
      'NetAnnualValue': hp.netAnnualValue,
      'StandardDeduction': hp.standardDeduction30Percent,
      'InterestOnLoan': hp.interestOnLoan,
      'IncomeFromHP': hp.incomeFromHouseProperty,
    };
  }

  static Map<String, dynamic> _otherSourceSchedule(Itr1FormData data) {
    final os = data.otherSourceIncome;
    return {
      'SavingsAccountInterest': os.savingsAccountInterest,
      'FDInterest': os.fixedDepositInterest,
      'DividendIncome': os.dividendIncome,
      'FamilyPension': os.familyPension,
      'OtherIncome': os.otherIncome,
      'TotalOtherSourceIncome': os.total,
    };
  }

  static Map<String, dynamic> _deductionsSchedule(Itr1FormData data) {
    final d = data.deductions;
    return {
      'Section80C': d.section80C,
      'Section80CCD1B': d.section80CCD1B,
      'Section80D_Self': d.section80DSelf,
      'Section80D_Parents': d.section80DParents,
      'Section80E': d.section80E,
      'Section80G': d.section80G,
      'Section80TTA': d.section80TTA,
      'Section80TTB': d.section80TTB,
      'TotalChapterVIA': d.totalDeductions,
    };
  }

  static Map<String, dynamic> _partBTotalIncome(
    Itr1FormData data,
    TaxRegimeResult taxResult,
  ) {
    return {
      'GrossTotalIncome': data.grossTotalIncome,
      'TotalDeductions': data.allowableDeductions,
      'TotalIncome_OldRegime': taxResult.oldRegimeTaxableIncome,
      'TotalIncome_NewRegime': taxResult.newRegimeTaxableIncome,
    };
  }

  static Map<String, dynamic> _partBTaxComputation(TaxRegimeResult result) {
    return {
      'OldRegime': {
        'TaxableIncome': result.oldRegimeTaxableIncome,
        'TaxOnIncome': result.oldRegimeTaxBeforeCess,
        'Surcharge': result.oldRegimeSurcharge,
        'HealthEducationCess': result.oldRegimeCess,
        'TotalTaxPayable': result.oldRegimeTax,
      },
      'NewRegime': {
        'TaxableIncome': result.newRegimeTaxableIncome,
        'TaxOnIncome': result.newRegimeTaxBeforeCess,
        'Surcharge': result.newRegimeSurcharge,
        'HealthEducationCess': result.newRegimeCess,
        'TotalTaxPayable': result.newRegimeTax,
      },
      'RecommendedRegime': result.recommendedRegime.label,
      'Savings': result.savings,
    };
  }

  static Map<String, dynamic> _verification(Itr1FormData data) {
    final pi = data.personalInfo;
    return {
      'Declaration': {
        'AssesseeVerName': '${pi.firstName} ${pi.lastName}',
        'FatherName': '',
        'Place': pi.city,
      },
    };
  }

  static String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm/${date.year}';
  }
}
