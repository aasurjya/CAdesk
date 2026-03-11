import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// StartupCalculator
// ---------------------------------------------------------------------------

/// Pure calculator for DPIIT / Startup India compliance rules.
class StartupCalculator {
  StartupCalculator._();

  /// DPIIT Startup eligibility criteria.
  static bool isDpiitEligible({
    required double annualTurnoverCrore,
    required int yearsFromIncorporation,
    required bool isInnovativeOrScalable,
    required bool isNewEntity,
  }) {
    return annualTurnoverCrore <= 100 &&
        yearsFromIncorporation <= 10 &&
        isInnovativeOrScalable &&
        isNewEntity;
  }

  /// Section 80-IAC: 100% deduction on profits for 3 years out of first 10.
  static double deduction80IAC({
    required double profit,
    required bool isEligible,
  }) {
    if (!isEligible) return 0;
    return profit;
  }

  /// Angel tax exemption under Sec 56(2)(viib) for DPIIT recognised startups.
  static bool isAngelTaxExempt(bool isDpiitRecognized) => isDpiitRecognized;

  /// Carry forward of losses allowed even if 51% shareholding changes
  /// (Sec 79 relaxed for DPIIT recognised startups).
  static bool canCarryForwardLoss(bool isDpiitRecognized) => isDpiitRecognized;

  /// Returns the next compliance action required for the startup.
  static String nextComplianceDue({
    required bool has80IacCert,
    required bool hasDpiitRecognition,
  }) {
    if (!hasDpiitRecognition) {
      return 'Apply for DPIIT recognition (DPIIT-1)';
    }
    if (!has80IacCert) {
      return 'Apply for 80-IAC certificate (Form DPIIT-2)';
    }
    return 'Annual compliance — DPIIT status renewal';
  }
}

// ---------------------------------------------------------------------------
// StartupStatus
// ---------------------------------------------------------------------------

/// Operational status of a startup.
enum StartupStatus {
  active('Active'),
  dormant('Dormant'),
  fundingRound('Funding Round'),
  exited('Exited');

  const StartupStatus(this.label);

  final String label;
}

// ---------------------------------------------------------------------------
// StartupProfile
// ---------------------------------------------------------------------------

/// Extended immutable model used for the detail sheet and mock data.
@immutable
class StartupProfile {
  const StartupProfile({
    required this.id,
    required this.name,
    required this.cin,
    required this.sectorVertical,
    required this.incorporationYear,
    required this.isDpiitRecognized,
    required this.has80IacCertificate,
    required this.annualTurnoverCrore,
    required this.currentYearProfit,
    required this.raisedFundingCrore,
    required this.esopPoolPercent,
    required this.founderPercent,
    required this.investorPercent,
    required this.status,
  });

  final String id;
  final String name;
  final String cin;
  final String sectorVertical;
  final int incorporationYear;
  final bool isDpiitRecognized;
  final bool has80IacCertificate;

  /// Annual turnover in crores.
  final double annualTurnoverCrore;

  /// Current year profit in crores (for 80-IAC calculation).
  final double currentYearProfit;

  /// Total funding raised in crores.
  final double raisedFundingCrore;

  final double esopPoolPercent;
  final double founderPercent;
  final double investorPercent;
  final StartupStatus status;

  bool get isDpiitEligible => StartupCalculator.isDpiitEligible(
        annualTurnoverCrore: annualTurnoverCrore,
        yearsFromIncorporation: DateTime.now().year - incorporationYear,
        isInnovativeOrScalable: true,
        isNewEntity: true,
      );

  /// 80-IAC deduction amount in crores.
  double get deduction80IACCrore => StartupCalculator.deduction80IAC(
        profit: currentYearProfit,
        isEligible: has80IacCertificate,
      );

  /// Tax saving at 25% rate in crores.
  double get taxSavingCrore => deduction80IACCrore * 0.25;

  bool get isAngelTaxExempt =>
      StartupCalculator.isAngelTaxExempt(isDpiitRecognized);
  bool get canCarryForwardLoss =>
      StartupCalculator.canCarryForwardLoss(isDpiitRecognized);

  String get nextComplianceDue => StartupCalculator.nextComplianceDue(
        has80IacCert: has80IacCertificate,
        hasDpiitRecognition: isDpiitRecognized,
      );

  StartupProfile copyWith({
    String? id,
    String? name,
    String? cin,
    String? sectorVertical,
    int? incorporationYear,
    bool? isDpiitRecognized,
    bool? has80IacCertificate,
    double? annualTurnoverCrore,
    double? currentYearProfit,
    double? raisedFundingCrore,
    double? esopPoolPercent,
    double? founderPercent,
    double? investorPercent,
    StartupStatus? status,
  }) {
    return StartupProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      cin: cin ?? this.cin,
      sectorVertical: sectorVertical ?? this.sectorVertical,
      incorporationYear: incorporationYear ?? this.incorporationYear,
      isDpiitRecognized: isDpiitRecognized ?? this.isDpiitRecognized,
      has80IacCertificate: has80IacCertificate ?? this.has80IacCertificate,
      annualTurnoverCrore: annualTurnoverCrore ?? this.annualTurnoverCrore,
      currentYearProfit: currentYearProfit ?? this.currentYearProfit,
      raisedFundingCrore: raisedFundingCrore ?? this.raisedFundingCrore,
      esopPoolPercent: esopPoolPercent ?? this.esopPoolPercent,
      founderPercent: founderPercent ?? this.founderPercent,
      investorPercent: investorPercent ?? this.investorPercent,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cin == other.cin &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, cin, status);

  @override
  String toString() =>
      'StartupProfile(name: $name, cin: $cin, status: ${status.label})';
}
