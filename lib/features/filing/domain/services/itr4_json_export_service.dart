import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr4/itr4_form_data.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';

/// Converts [Itr4FormData] + [TaxRegimeResult] into a [Map] matching the
/// ITD JSON schema structure for ITR-4 (Sugam) filing.
///
/// The CA downloads this JSON and uploads it to the Income Tax portal.
class Itr4JsonExportService {
  Itr4JsonExportService._();

  /// Generate the full ITR-4 JSON structure.
  static Map<String, dynamic> export({
    required Itr4FormData formData,
    required TaxRegimeResult taxResult,
    required String assessmentYear,
    required String filingType, // 'Original' or 'Revised'
  }) {
    return {
      'ITR': {
        'ITR4': {
          'CreationInfo': _creationInfo(assessmentYear, filingType),
          'PartA_GEN1': _personalInfo(formData),
          'Schedule44AD': _schedule44AD(formData),
          'Schedule44ADA': _schedule44ADA(formData),
          'Schedule44AE': _schedule44AE(formData),
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

  static Map<String, dynamic> _personalInfo(Itr4FormData data) {
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
        'ReturnFileSec': 11, // Section 139(1)
        'OptOutNewTaxRegime': data.selectedRegime == TaxRegime.oldRegime
            ? 'Y'
            : 'N',
      },
    };
  }

  static Map<String, dynamic> _schedule44AD(Itr4FormData data) {
    final b = data.businessIncome44AD;
    return {
      'NatureOfBusiness': b.natureOfBusiness,
      'TradeName': b.tradeName,
      'GrossTurnover': b.turnover,
      'CashTurnover': b.cashTurnover,
      'NonCashTurnover': b.nonCashTurnover,
      'PresumptiveIncome44AD': b.presumptiveIncome,
    };
  }

  static Map<String, dynamic> _schedule44ADA(Itr4FormData data) {
    final p = data.professionIncome44ADA;
    return {
      'NatureOfProfession': p.natureOfProfession,
      'GrossReceipts': p.grossReceipts,
      'PresumptiveIncome44ADA': p.presumptiveIncome,
    };
  }

  static Map<String, dynamic> _schedule44AE(Itr4FormData data) {
    final g = data.goodsCarriageIncome44AE;
    return {
      'NumberOfVehicles': g.numberOfVehicles,
      'MonthsOperatedPerVehicle': g.monthsOperatedPerVehicle,
      'PresumptiveIncome44AE': g.presumptiveIncome,
    };
  }

  static Map<String, dynamic> _otherSourceSchedule(Itr4FormData data) {
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

  static Map<String, dynamic> _deductionsSchedule(Itr4FormData data) {
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
    Itr4FormData data,
    TaxRegimeResult taxResult,
  ) {
    return {
      'PresumptiveIncome44AD': data.businessIncome44AD.presumptiveIncome,
      'PresumptiveIncome44ADA': data.professionIncome44ADA.presumptiveIncome,
      'PresumptiveIncome44AE': data.goodsCarriageIncome44AE.presumptiveIncome,
      'TotalPresumptiveIncome': data.totalPresumptiveIncome,
      'IncomeFromOtherSources': data.otherSourceIncome.total,
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

  static Map<String, dynamic> _verification(Itr4FormData data) {
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
