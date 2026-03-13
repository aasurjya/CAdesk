import 'dart:convert';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr_checksum_service.dart';

/// Stateless service that exports [Itr2FormData] to the ITD e-Filing 2.0
/// JSON format and wraps the result in an [ItrExportResult].
///
/// ITR-2 includes capital gains schedules per Finance Act 2024:
/// - STCG 111A at 20% (listed equity / MF, held ≤ 12 months)
/// - LTCG 112A at 12.5% above ₹1.25L exemption (listed equity / MF,
///   held > 12 months)
/// - Schedule FA: foreign assets disclosure
/// - Schedule AL: assets & liabilities if income > ₹50L
///
/// All monetary amounts are encoded as **integers in rupees**.
class Itr2ExportService {
  Itr2ExportService._();

  /// Exports [data] for the given [assessmentYear] (format "YYYY-YY").
  static ItrExportResult export(Itr2FormData data, String assessmentYear) {
    final payload = _buildPayload(data, assessmentYear);
    final jsonString = jsonEncode(payload);
    final checksum = ItrChecksumService.computeSha256(jsonString);

    return ItrExportResult(
      itrType: ItrType.itr2,
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
    Itr2FormData data,
    String assessmentYear,
  ) {
    final itr2Map = <String, dynamic>{
      'PersonalInfo': _personalInfo(data, assessmentYear),
      'FilingStatus': _filingStatus(data),
      'ScheduleS': _salarySchedule(data),
      'ScheduleHP': _housePropertySchedule(data),
      'ScheduleOS': _otherSourceSchedule(data),
      'ScheduleVIA': _deductionsSchedule(data),
      'ScheduleCG': _capitalGainsSchedule(data),
      'Schedule112A': _schedule112A(data),
      'ScheduleFA': _foreignAssetsSchedule(data),
      'PartBTI': _partBTotalIncome(data),
    };

    if (data.requiresScheduleAL && data.scheduleAl != null) {
      itr2Map['ScheduleAL'] = _scheduleAl(data);
    }

    return {
      'ITR': {'ITR2': itr2Map},
    };
  }

  static Map<String, dynamic> _personalInfo(
    Itr2FormData data,
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

  static Map<String, dynamic> _filingStatus(Itr2FormData data) {
    return {
      'ReturnFileSec': 11,
      'SeqNoOfSelf': '1',
      'OptOutNewTaxRegime': data.selectedRegime == TaxRegime.oldRegime
          ? 'Y'
          : 'N',
    };
  }

  static Map<String, dynamic> _salarySchedule(Itr2FormData data) {
    final s = data.salaryIncome;
    return {
      'Salaries': _toRupees(s.grossSalary),
      'AllwncExemptUs10': _toRupees(s.allowancesExemptUnderSection10),
      'Perquisites': _toRupees(s.valueOfPerquisites),
      'ProfitsInSalary': _toRupees(s.profitsInLieuOfSalary),
      'DeductionUs16': _toRupees(s.standardDeduction),
      'NetSalary': _toRupees(s.netSalary),
    };
  }

  static Map<String, dynamic> _housePropertySchedule(Itr2FormData data) {
    final hp = data.housePropertyIncome;
    return {
      'AnnualLetableValue': _toRupees(hp.annualLetableValue),
      'MunicipalTaxPaid': _toRupees(hp.municipalTaxesPaid),
      'NetAnnualValue': _toRupees(hp.netAnnualValue),
      'StandardDeduction': _toRupees(hp.standardDeduction30Percent),
      'InterestOnLoan': _toRupees(hp.interestOnLoan),
      'IncomeFromHP': _toRupees(hp.incomeFromHouseProperty),
    };
  }

  static Map<String, dynamic> _otherSourceSchedule(Itr2FormData data) {
    final os = data.otherSourceIncome;
    return {
      'SavingsAccountInterest': _toRupees(os.savingsAccountInterest),
      'FDInterest': _toRupees(os.fixedDepositInterest),
      'DividendIncome': _toRupees(os.dividendIncome),
      'FamilyPension': _toRupees(os.familyPension),
      'OtherIncome': _toRupees(os.otherIncome),
      'TotalOtherSourceIncome': _toRupees(os.total),
    };
  }

  static Map<String, dynamic> _deductionsSchedule(Itr2FormData data) {
    final d = data.deductions;
    return {
      'Section80C': _toRupees(d.section80C),
      'Section80CCD1B': _toRupees(d.section80CCD1B),
      'Section80D_Self': _toRupees(d.section80DSelf),
      'Section80D_Parents': _toRupees(d.section80DParents),
      'Section80E': _toRupees(d.section80E),
      'Section80G': _toRupees(d.section80G),
      'Section80TTA': _toRupees(d.section80TTA),
      'Section80TTB': _toRupees(d.section80TTB),
      'TotalChapterVIA': _toRupees(d.totalDeductions),
    };
  }

  /// Builds Schedule CG following Finance Act 2024 rates:
  /// - STCG 111A: 20% (listed equity/MF short-term)
  /// - LTCG 112A: 12.5% above ₹1.25L (listed equity/MF long-term)
  /// - LTCG on property: 20%
  static Map<String, dynamic> _capitalGainsSchedule(Itr2FormData data) {
    final cg = data.scheduleCg;
    return {
      'ShortTerm': {
        'STCG_111A': {
          'TotalSTCG': _toRupees(cg.totalStcg111A),
          'TaxRate': 20,
          'Tax': _stcg111ATax(cg.totalStcg111A),
        },
        'STCG_Other': {
          'TotalSTCG': _toRupees(cg.totalStcgOther),
          'Note': 'Taxable at slab rate',
        },
      },
      'LongTerm': {
        'LTCG_112A': {
          'TotalLTCG': _toRupees(cg.totalLtcg112A),
          'ExemptionLimit': 125000,
          'TaxRate': 12.5,
          'Tax': _ltcg112ATax(cg.totalLtcg112A),
        },
        'LTCG_Property': {
          'TotalLTCG': _toRupees(cg.totalLtcgOnProperty),
          'TaxRate': 20,
          'Tax': _toRupees(cg.totalLtcgOnProperty * 0.20),
        },
        'LTCG_Other': {
          'TotalLTCG': _toRupees(cg.totalLtcgOther),
          'TaxRate': 20,
          'Tax': _toRupees(cg.totalLtcgOther * 0.20),
        },
      },
      'SetOff': {
        'BroughtForwardSTCL': _toRupees(cg.broughtForwardStcl),
        'BroughtForwardLTCL': _toRupees(cg.broughtForwardLtcl),
        'NetSTCGAfterSetOff': _toRupees(cg.netStcgAfterSetOff),
        'NetLTCGAfterSetOff': _toRupees(cg.netLtcgAfterSetOff),
      },
    };
  }

  /// Builds Schedule 112A for listed equity / MF LTCG entries.
  static Map<String, dynamic> _schedule112A(Itr2FormData data) {
    final entries = data.scheduleCg.equityLtcgEntries;
    return {
      'TotalEntries': entries.length,
      'ExemptionLimit': 125000,
      'Entries': entries.map((e) {
        return {
          'Description': e.description,
          'SaleConsideration': _toRupees(e.salePrice),
          'ActualCostOfAcquisition': _toRupees(e.costOfAcquisition),
          'FMVOn31Jan2018': _toRupees(e.fmvOn31Jan2018),
          'EffectiveCostOfAcquisition': _toRupees(e.effectiveCostOfAcquisition),
          'CapitalGain': _toRupees(e.gain),
        };
      }).toList(),
    };
  }

  static Map<String, dynamic> _foreignAssetsSchedule(Itr2FormData data) {
    final fa = data.foreignAssetSchedule;
    return {
      'TotalForeignAssets': fa.assets.length,
      'TotalValueInINR': _toRupees(fa.totalValueInINR),
      'Assets': fa.assets.map((a) {
        return {
          'CountryCode': a.countryCode,
          'CountryName': a.countryName,
          'AssetType': a.assetType.label,
          'Description': a.description,
          'ValueInINR': _toRupees(a.valueInINR),
          'IncomeDerived': _toRupees(a.incomeDerived),
          'IncomeOffered': _toRupees(a.incomeOffered),
        };
      }).toList(),
    };
  }

  static Map<String, dynamic> _scheduleAl(Itr2FormData data) {
    final al = data.scheduleAl!;
    return {
      'ImmovableProperty': _toRupees(al.immovablePropertyValue),
      'MovableProperty': _toRupees(al.movablePropertyValue),
      'FinancialAssets': _toRupees(al.financialAssetValue),
      'TotalAssets': _toRupees(al.totalAssets),
      'TotalLiabilities': _toRupees(al.totalLiabilities),
      'NetWorth': _toRupees(al.netWorth),
    };
  }

  static Map<String, dynamic> _partBTotalIncome(Itr2FormData data) {
    return {
      'OrdinaryIncome': _toRupees(data.ordinaryIncome),
      'CapitalGainsTotal': _toRupees(data.capitalGainsTotal),
      'ForeignIncome': _toRupees(data.foreignAssetSchedule.totalIncomeOffered),
      'GrossTotalIncome': _toRupees(data.grossTotalIncome),
      'TotalDeductions': _toRupees(data.allowableDeductions),
      'TaxableOrdinaryIncome': _toRupees(data.taxableOrdinaryIncome),
      'TotalTaxableIncome': _toRupees(data.taxableIncome),
    };
  }

  // ---------------------------------------------------------------------------
  // Tax computation helpers (Finance Act 2024 rates)
  // ---------------------------------------------------------------------------

  /// STCG 111A tax: 20% flat (Finance Act 2024 increased from 15% to 20%).
  static int _stcg111ATax(double stcg) => _toRupees(stcg * 0.20);

  /// LTCG 112A tax: 12.5% on amount exceeding ₹1.25L exemption limit.
  ///
  /// Finance Act 2024: rate raised from 10% to 12.5%, exemption ₹1L → ₹1.25L.
  static int _ltcg112ATax(double ltcg) {
    const exemption = 125000.0;
    final taxable = ltcg > exemption ? ltcg - exemption : 0.0;
    return _toRupees(taxable * 0.125);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static int _toRupees(double amount) => amount.truncate();

  static String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
