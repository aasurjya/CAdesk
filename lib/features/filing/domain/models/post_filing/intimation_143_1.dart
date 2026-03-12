/// Processing status of an Intimation under Section 143(1).
enum IntimationStatus {
  noDeviations('No Deviations — Accepted as Filed'),
  demandRaised('Demand Raised'),
  refundDetermined('Refund Determined'),
  partiallyAdjusted('Partially Adjusted');

  const IntimationStatus(this.label);
  final String label;
}

/// Immutable model representing an Intimation under Section 143(1)
/// of the Income Tax Act — the CPC's automated processing result.
class Intimation1431 {
  const Intimation1431({
    required this.intimationDate,
    required this.assessmentYear,
    required this.pan,
    required this.processingStatus,
    required this.demandAmount,
    required this.refundAmount,
    required this.incomeAsPerReturn,
    required this.incomeAsPerProcessing,
    required this.taxAsPerReturn,
    required this.taxAsPerProcessing,
    required this.remarks,
  });

  final DateTime intimationDate;
  final String assessmentYear;
  final String pan;
  final IntimationStatus processingStatus;
  final double demandAmount;
  final double refundAmount;
  final double incomeAsPerReturn;
  final double incomeAsPerProcessing;
  final double taxAsPerReturn;
  final double taxAsPerProcessing;
  final String remarks;

  Intimation1431 copyWith({
    DateTime? intimationDate,
    String? assessmentYear,
    String? pan,
    IntimationStatus? processingStatus,
    double? demandAmount,
    double? refundAmount,
    double? incomeAsPerReturn,
    double? incomeAsPerProcessing,
    double? taxAsPerReturn,
    double? taxAsPerProcessing,
    String? remarks,
  }) {
    return Intimation1431(
      intimationDate: intimationDate ?? this.intimationDate,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      pan: pan ?? this.pan,
      processingStatus: processingStatus ?? this.processingStatus,
      demandAmount: demandAmount ?? this.demandAmount,
      refundAmount: refundAmount ?? this.refundAmount,
      incomeAsPerReturn: incomeAsPerReturn ?? this.incomeAsPerReturn,
      incomeAsPerProcessing:
          incomeAsPerProcessing ?? this.incomeAsPerProcessing,
      taxAsPerReturn: taxAsPerReturn ?? this.taxAsPerReturn,
      taxAsPerProcessing: taxAsPerProcessing ?? this.taxAsPerProcessing,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Intimation1431 &&
        other.intimationDate == intimationDate &&
        other.assessmentYear == assessmentYear &&
        other.pan == pan &&
        other.processingStatus == processingStatus &&
        other.demandAmount == demandAmount &&
        other.refundAmount == refundAmount &&
        other.incomeAsPerReturn == incomeAsPerReturn &&
        other.incomeAsPerProcessing == incomeAsPerProcessing &&
        other.taxAsPerReturn == taxAsPerReturn &&
        other.taxAsPerProcessing == taxAsPerProcessing &&
        other.remarks == remarks;
  }

  @override
  int get hashCode => Object.hash(
    intimationDate,
    assessmentYear,
    pan,
    processingStatus,
    demandAmount,
    refundAmount,
    incomeAsPerReturn,
    incomeAsPerProcessing,
    taxAsPerReturn,
    taxAsPerProcessing,
    remarks,
  );
}
