/// Single row in an amortization schedule.
class AmortizationEntry {
  const AmortizationEntry({
    required this.month,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  final int month;
  final double emi;
  final double principal;
  final double interest;

  /// Outstanding balance after this payment.
  final double balance;

  AmortizationEntry copyWith({
    int? month,
    double? emi,
    double? principal,
    double? interest,
    double? balance,
  }) {
    return AmortizationEntry(
      month: month ?? this.month,
      emi: emi ?? this.emi,
      principal: principal ?? this.principal,
      interest: interest ?? this.interest,
      balance: balance ?? this.balance,
    );
  }
}

/// Immutable loan calculator model with EMI and amortization schedule.
class LoanCalculator {
  const LoanCalculator({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.loanAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.disbursementDate,
    required this.amortizationSchedule,
  });

  final String id;
  final String clientId;
  final String clientName;
  final double loanAmount;

  /// Annual interest rate in percent (e.g. 8.5 for 8.5%).
  final double interestRate;
  final int tenureMonths;
  final double emi;
  final double totalInterest;
  final double totalPayment;
  final DateTime disbursementDate;
  final List<AmortizationEntry> amortizationSchedule;

  /// Months elapsed from disbursement to today (mocked as Mar 2026).
  int get monthsElapsed {
    final today = _mockToday;
    final diff = (today.year - disbursementDate.year) * 12 +
        today.month -
        disbursementDate.month;
    return diff.clamp(0, tenureMonths);
  }

  double get progressFraction =>
      tenureMonths > 0 ? monthsElapsed / tenureMonths : 0;

  LoanCalculator copyWith({
    String? id,
    String? clientId,
    String? clientName,
    double? loanAmount,
    double? interestRate,
    int? tenureMonths,
    double? emi,
    double? totalInterest,
    double? totalPayment,
    DateTime? disbursementDate,
    List<AmortizationEntry>? amortizationSchedule,
  }) {
    return LoanCalculator(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      loanAmount: loanAmount ?? this.loanAmount,
      interestRate: interestRate ?? this.interestRate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      emi: emi ?? this.emi,
      totalInterest: totalInterest ?? this.totalInterest,
      totalPayment: totalPayment ?? this.totalPayment,
      disbursementDate: disbursementDate ?? this.disbursementDate,
      amortizationSchedule: amortizationSchedule ?? this.amortizationSchedule,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanCalculator &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Mock today date used across the module.
final _mockToday = DateTime.utc(2026, 3, 10);

/// Computes EMI using the standard reducing-balance formula.
double computeEmi(double principal, double annualRatePct, int tenureMonths) {
  if (tenureMonths == 0) return 0;
  final r = annualRatePct / 12 / 100;
  if (r == 0) return principal / tenureMonths;
  final pow = (1 + r);
  double p = pow;
  for (var i = 1; i < tenureMonths; i++) {
    p *= pow;
  }
  return principal * r * p / (p - 1);
}

/// Builds a full amortization schedule for the given loan parameters.
List<AmortizationEntry> buildAmortizationSchedule(
  double principal,
  double annualRatePct,
  int tenureMonths,
  double emi,
) {
  final entries = <AmortizationEntry>[];
  final r = annualRatePct / 12 / 100;
  var balance = principal;

  for (var m = 1; m <= tenureMonths; m++) {
    final interest = balance * r;
    final principalPaid = emi - interest;
    balance = (balance - principalPaid).clamp(0, double.infinity);
    entries.add(AmortizationEntry(
      month: m,
      emi: emi,
      principal: principalPaid,
      interest: interest,
      balance: balance,
    ));
  }
  return List.unmodifiable(entries);
}
