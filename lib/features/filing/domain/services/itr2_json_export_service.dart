import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_112a.dart';
import 'package:ca_app/features/filing/domain/services/capital_gains_computation_service.dart';

/// Converts [Itr2FormData] into a [Map] matching the ITD JSON schema structure
/// for ITR-2 filing.
///
/// The CA downloads this JSON and uploads it to the Income Tax portal.
///
/// Schedule structure:
/// - PartA_GEN1: Personal information and filing status
/// - ScheduleS: Salary income (Schedule S)
/// - ScheduleHP: House property income (Schedule HP)
/// - ScheduleOS: Other source income (Schedule OS)
/// - ScheduleVIA: Chapter VI-A deductions
/// - ScheduleCG: Capital gains computation
/// - Schedule112A: Listed equity/MF LTCG with grandfathering
/// - ScheduleFA: Foreign assets (if any)
/// - ScheduleAL: Assets and liabilities (if total income > ₹50L)
/// - PartBTI: Total income aggregation
/// - PartBTTI: Tax computation
class Itr2JsonExportService {
  Itr2JsonExportService._();

  /// Generate the full ITR-2 JSON structure.
  static Map<String, dynamic> export({
    required Itr2FormData formData,
    required CapitalGainsTaxResult cgTaxResult,
    required Schedule112a schedule112a,
    required String assessmentYear,
    required String filingType,
  }) {
    return {
      'ITR': {
        'ITR2': {
          'CreationInfo': _creationInfo(assessmentYear, filingType),
          'PartA_GEN1': _personalInfo(formData),
          'ScheduleS': _salarySchedule(formData),
          'ScheduleHP': _housePropertySchedule(formData),
          'ScheduleOS': _otherSourceSchedule(formData),
          'ScheduleVIA': _deductionsSchedule(formData),
          'ScheduleCG': _capitalGainsSchedule(formData, cgTaxResult),
          'Schedule112A': _schedule112A(schedule112a),
          'ScheduleFA': _foreignAssetsSchedule(formData),
          if (formData.scheduleAl != null) 'ScheduleAL': _scheduleAl(formData),
          'PartBTI': _partBTotalIncome(formData, cgTaxResult),
          'PartBTTI': _partBTaxComputation(formData, cgTaxResult),
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
      'AssessmentYear': assessmentYear,
      'FilingType': filingType,
    };
  }

  static Map<String, dynamic> _personalInfo(Itr2FormData data) {
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
        'ReturnFileSec': 11,
        'OptOutNewTaxRegime': data.selectedRegime == TaxRegime.oldRegime
            ? 'Y'
            : 'N',
      },
    };
  }

  static Map<String, dynamic> _salarySchedule(Itr2FormData data) {
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

  static Map<String, dynamic> _housePropertySchedule(Itr2FormData data) {
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

  static Map<String, dynamic> _otherSourceSchedule(Itr2FormData data) {
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

  static Map<String, dynamic> _deductionsSchedule(Itr2FormData data) {
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

  static Map<String, dynamic> _capitalGainsSchedule(
    Itr2FormData data,
    CapitalGainsTaxResult cgResult,
  ) {
    final cg = data.scheduleCg;
    return {
      'ShortTerm': {
        'STCG_111A': {
          'TotalSTCG': cg.totalStcg111A,
          'TaxRate': 20,
          'Tax': cgResult.stcg111ATax,
        },
        'STCG_Other': {
          'TotalSTCG': cg.totalStcgOther,
          'Note': 'Taxable at slab rate',
        },
      },
      'LongTerm': {
        'LTCG_112A': {
          'TotalLTCG': cg.totalLtcg112A,
          'TaxRate': 12.5,
          'Tax': cgResult.ltcg112ATax,
        },
        'LTCG_Property': {
          'TotalLTCG': cg.totalLtcgOnProperty,
          'TaxRate': 20,
          'Tax': cgResult.ltcgOnPropertyTax,
        },
        'LTCG_Other': {
          'TotalLTCG': cg.totalLtcgOther,
          'TaxRate': 20,
          'Tax': cgResult.ltcgOtherTax,
        },
      },
      'SetOff': {
        'BroughtForwardSTCL': cg.broughtForwardStcl,
        'BroughtForwardLTCL': cg.broughtForwardLtcl,
        'NetSTCGAfterSetOff': cg.netStcgAfterSetOff,
        'NetLTCGAfterSetOff': cg.netLtcgAfterSetOff,
      },
      'TotalCapitalGainsTax': cgResult.totalCgTax,
    };
  }

  static Map<String, dynamic> _schedule112A(Schedule112a schedule) {
    return {
      'TotalEntries': schedule.entries.length,
      'TotalGain': schedule.totalGain,
      'ExemptionLimit': 125000,
      'TaxableGain': schedule.taxableGain,
      'Entries': schedule.entries.map((e) {
        return {
          'ISIN': e.isin,
          'AssetName': e.assetName,
          'UnitsOrShares': e.unitsOrShares,
          'SaleConsideration': e.salePrice,
          'ActualCostOfAcquisition': e.costOfAcquisition,
          'FMVOn31Jan2018': e.fmvOn31Jan2018,
          'EffectiveCostOfAcquisition': e.effectiveCostOfAcquisition,
          'CapitalGain': e.gain,
          'SaleDate': e.saleDate,
          'AcquisitionDate': e.acquisitionDate,
        };
      }).toList(),
    };
  }

  static Map<String, dynamic> _foreignAssetsSchedule(Itr2FormData data) {
    final fa = data.foreignAssetSchedule;
    return {
      'TotalForeignAssets': fa.assets.length,
      'TotalValueInINR': fa.totalValueInINR,
      'TotalIncomeDerived': fa.totalIncomeDerived,
      'TotalIncomeOffered': fa.totalIncomeOffered,
      'Assets': fa.assets.map((a) {
        return {
          'CountryCode': a.countryCode,
          'CountryName': a.countryName,
          'AssetType': a.assetType.label,
          'Description': a.description,
          'ValueInForeignCurrency': a.valueInForeignCurrency,
          'ExchangeRate': a.exchangeRate,
          'ValueInINR': a.valueInINR,
          'AcquisitionDate': a.acquisitionDate,
          'IncomeDerived': a.incomeDerived,
          'IncomeOffered': a.incomeOffered,
        };
      }).toList(),
    };
  }

  static Map<String, dynamic> _scheduleAl(Itr2FormData data) {
    final al = data.scheduleAl!;
    return {
      'ImmovableProperty': al.immovablePropertyValue,
      'MovableProperty': al.movablePropertyValue,
      'FinancialAssets': al.financialAssetValue,
      'TotalAssets': al.totalAssets,
      'TotalLiabilities': al.totalLiabilities,
      'NetWorth': al.netWorth,
    };
  }

  static Map<String, dynamic> _partBTotalIncome(
    Itr2FormData data,
    CapitalGainsTaxResult cgResult,
  ) {
    return {
      'OrdinaryIncome': data.ordinaryIncome,
      'CapitalGainsTotal': data.capitalGainsTotal,
      'ForeignIncome': data.foreignAssetSchedule.totalIncomeOffered,
      'GrossTotalIncome': data.grossTotalIncome,
      'TotalDeductions': data.allowableDeductions,
      'TaxableOrdinaryIncome': data.taxableOrdinaryIncome,
      'TotalTaxableIncome': data.taxableIncome,
    };
  }

  static Map<String, dynamic> _partBTaxComputation(
    Itr2FormData data,
    CapitalGainsTaxResult cgResult,
  ) {
    return {
      'TaxRegime': data.selectedRegime.label,
      'TaxOnOrdinaryIncome': 0, // computed by main tax engine, not CG service
      'STCG111ATax': cgResult.stcg111ATax,
      'LTCG112ATax': cgResult.ltcg112ATax,
      'LTCGPropertyTax': cgResult.ltcgOnPropertyTax,
      'LTCGOtherTax': cgResult.ltcgOtherTax,
      'TotalCapitalGainsTax': cgResult.totalCgTax,
    };
  }

  static Map<String, dynamic> _verification(Itr2FormData data) {
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
