import 'filing_status_transition.dart';

/// Type of tax filing.
enum FilingType {
  itr('ITR'),
  gst('GST'),
  tds('TDS'),
  mca('MCA');

  const FilingType(this.label);
  final String label;
}

/// States in the ITR filing lifecycle state machine.
///
/// Flow:
///   draft → submitted → eVerificationPending → eVerified
///         → processing → processed
///         → defective | intimationIssued | refundInitiated | demandRaised
enum FilingState {
  draft('Draft'),
  submitted('Submitted'),
  eVerificationPending('E-Verification Pending'),
  eVerified('E-Verified'),
  processing('Processing at CPC'),
  processed('Processed'),
  defective('Defective Notice Issued'),
  intimationIssued('Intimation u/s 143(1) Issued'),
  refundInitiated('Refund Initiated'),
  demandRaised('Demand Raised');

  const FilingState(this.label);
  final String label;
}

/// Immutable model representing the full status of an ITR/GST/TDS/MCA filing,
/// including its current lifecycle state and complete transition history.
class FilingStatus {
  const FilingStatus({
    required this.filingId,
    required this.filingType,
    required this.pan,
    required this.period,
    required this.submittedAt,
    required this.currentState,
    this.acknowledgementNumber,
    this.history = const [],
  });

  final String filingId;
  final FilingType filingType;

  /// PAN, GSTIN, or TAN depending on [filingType].
  final String pan;

  /// Assessment year or return period (e.g. "2024-25" or "032025").
  final String period;

  final DateTime submittedAt;
  final FilingState currentState;

  /// Acknowledgement number issued by ITD/GST portal on successful submission.
  final String? acknowledgementNumber;

  /// Ordered list of state transitions from oldest to newest.
  final List<FilingStatusTransition> history;

  FilingStatus copyWith({
    String? filingId,
    FilingType? filingType,
    String? pan,
    String? period,
    DateTime? submittedAt,
    FilingState? currentState,
    String? acknowledgementNumber,
    List<FilingStatusTransition>? history,
  }) {
    return FilingStatus(
      filingId: filingId ?? this.filingId,
      filingType: filingType ?? this.filingType,
      pan: pan ?? this.pan,
      period: period ?? this.period,
      submittedAt: submittedAt ?? this.submittedAt,
      currentState: currentState ?? this.currentState,
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
      history: history ?? this.history,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilingStatus) return false;
    if (history.length != other.history.length) return false;
    for (var i = 0; i < history.length; i++) {
      if (history[i] != other.history[i]) return false;
    }
    return other.filingId == filingId &&
        other.filingType == filingType &&
        other.pan == pan &&
        other.period == period &&
        other.submittedAt == submittedAt &&
        other.currentState == currentState &&
        other.acknowledgementNumber == acknowledgementNumber;
  }

  @override
  int get hashCode => Object.hash(
    filingId,
    filingType,
    pan,
    period,
    submittedAt,
    currentState,
    acknowledgementNumber,
    Object.hashAll(history),
  );
}
